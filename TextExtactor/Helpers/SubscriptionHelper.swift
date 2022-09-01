//
//  SubscriptionHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation
import SwiftyStoreKit
import StoreKit

struct ProductInfo {
  let priceLocale: Locale
  let price: Double
  let period: SKProductSubscriptionPeriod?
  let intro:  SKProductSubscriptionPeriod?
}

enum Subscription: String, CaseIterable {
  typealias SubscriptionGroup = (main: Subscription, trial: Subscription)
  
  case weekly05 = "extractor.weekly.0.5"
  case monthly1 = "extractor.monthly.1"
  case monthly2 = "extractor.monthly.2"
  case monthlyTrial2 = "extractor.monthly.trial.2"
  case monthly5 = "extractor.monthly.5"
  case monthlyTrial5 = "extractor.monthly.trial.5"
  case annual15 = "extractor.annual.15"
  
  static var currentGroup: SubscriptionGroup {
    switch Locale.current.countryFlag {
    case 🇺🇸, 🇩🇪, 🇮🇹, 🇷🇺: return (main: .annual15, trial: .annual15)
    case 🇺🇦: return (main: .annual15, trial: .annual15)
    default: return (main: .annual15, trial: .annual15)
    }
  }
  
  static var currentDoubleGroup: DoublePaywallSubscriptions {
    (main: .annual15, secondary: .monthly2)
  }
}

struct SubscriptionHelper {
  static private let _secret = "6abad310fdd6442682dae9fd861bc2c2"
  
  static func purchase(_ subscription: Subscription = Subscription.currentGroup.main) {
    SwiftyStoreKit.purchaseProduct(subscription.rawValue, quantity: 1, atomically: true) { result in
      switch result {
      case .success:
        handleSubscription(subscription)
      case .error(let error):
        UserDefaults.standard.userSubscribed = false
        switch error.code {
        case .unknown: print("Unknown error. Please contact support")
        case .clientInvalid: print("Not allowed to make the payment")
        case .paymentCancelled: break
        case .paymentInvalid: print("The purchase identifier was invalid")
        case .paymentNotAllowed: print("The device is not allowed to make the payment")
        case .storeProductNotAvailable: print("The product is not available in the current storefront")
        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
        default: print((error as NSError).localizedDescription)
        }
      }
    }
  }
  
  static func subscribe(subscription: Subscription = Subscription.currentGroup.main, resultHandler: @escaping (PurchaseResult) -> Void ) {
    SwiftyStoreKit.purchaseProduct(subscription.rawValue, quantity: 1, atomically: true, completion: resultHandler)
  }
  
  static func handleSubscription(_ subs: Subscription) {
    
    let convertationDate: Date
    switch subs {
    case .weekly05, .monthly1, .monthly2, .monthly5, .annual15:
      convertationDate = Date()
    case .monthlyTrial2, .monthlyTrial5:
      let currentDate = Date()
      var dateComponent = DateComponents()
      dateComponent.day = 3
      convertationDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) ?? Date()
    }
    
    UserDefaults.standard.convertationDate = convertationDate
    UserDefaults.standard.userSubscribed = true
  }
  
  private static func verifyReceipt(resultHandler: @escaping (VerifyReceiptResult) -> Void ) {
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: _secret)
    SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: resultHandler)
  }
  
  static func verifySubscriptions(_ receipt:ReceiptInfo) -> VerifySubscriptionResult {
    return SwiftyStoreKit.verifySubscriptions(
      ofType: .autoRenewable,
      productIds: Set(Subscription.allCases.map(\.rawValue)),
      inReceipt: receipt)
  }
  
  static func restore(resultHandler: @escaping (VerifyReceiptResult) -> Void ) {
    verifyReceipt(resultHandler: resultHandler)
  }
  
  static func retrieveInfo(subscription: Subscription, completion: @escaping ((ProductInfo?) -> ())) {
    SwiftyStoreKit.retrieveProductsInfo([subscription.rawValue]) { result in
      if let product = result.retrievedProducts.first {
        let info = ProductInfo(priceLocale: product.priceLocale, price: product.price.doubleValue, period: product.subscriptionPeriod, intro: product.introductoryPrice?.subscriptionPeriod)
        completion(info)
      } else if let invalidProductId = result.invalidProductIDs.first {
        print("Invalid product identifier: \(invalidProductId)")
        completion(nil)
      } else {
        print("Error: \(result.error)")
        completion(nil)
      }
    }
  }
  
  static func completeTransactions() {
    SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
      for purchase in purchases {
        switch purchase.transaction.transactionState {
        case .purchased, .restored:
          if purchase.needsFinishTransaction {
            SwiftyStoreKit.finishTransaction(purchase.transaction)
          }
        case .failed, .purchasing, .deferred:
          break
        }
      }
    }
  }
  
  static func checkSubscription() {
    guard UserDefaults.standard.userSubscribed else { return }
    
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: _secret)
    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
      
      switch result {
      case .success(let receipt):
        // Verify the purchase of a Subscription
        let purchaseResult = SwiftyStoreKit.verifySubscriptions(
          ofType: .autoRenewable,
          productIds: Set(Subscription.allCases.map(\.rawValue)) ,
          inReceipt: receipt)
        
        DispatchQueue.main.async {
          switch purchaseResult {
          case .purchased:
            UserDefaults.standard.userSubscribed = true
            break
          case .expired:
            UserDefaults.standard.userSubscribed = false
            
          case .notPurchased:
            UserDefaults.standard.userSubscribed = false
          }
        }
      case .error:
        UserDefaults.standard.userSubscribed = false
      }
    }
  }
}
