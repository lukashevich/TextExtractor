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

struct SubscriptionHelper {
  static private let _secret = "6abad310fdd6442682dae9fd861bc2c2"
  static private let _currentSubscriptionID = "extractor.monthly.2"
  
  static func purchase() {
    SwiftyStoreKit.purchaseProduct(_currentSubscriptionID, quantity: 1, atomically: true) { result in
      switch result {
      case .success(let purchase):
        UserDefaults.standard.userSubscribed = true
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
  
  static func subscribe(resultHandler: @escaping (PurchaseResult) -> Void ) {
    SwiftyStoreKit.purchaseProduct(_currentSubscriptionID, quantity: 1, atomically: true, completion: resultHandler)
  }
  
  private static func verifyReceipt(resultHandler: @escaping (VerifyReceiptResult) -> Void ) {
    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: _secret)
    SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: resultHandler)
  }
  
  static func verifySubscriptions(_ receipt:ReceiptInfo) -> VerifySubscriptionResult {
    return SwiftyStoreKit.verifySubscriptions(
      ofType: .autoRenewable,
      productIds: [_currentSubscriptionID],
      inReceipt: receipt)
  }
  
  static func restore(resultHandler: @escaping (VerifyReceiptResult) -> Void ) {
    verifyReceipt(resultHandler: resultHandler)
  }
  
  static func retrieveInfo( completion: @escaping ((ProductInfo?) -> ())) {
    SwiftyStoreKit.retrieveProductsInfo([_currentSubscriptionID]) { result in
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
}
