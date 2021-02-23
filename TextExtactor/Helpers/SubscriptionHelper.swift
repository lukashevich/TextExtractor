//
//  SubscriptionHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation
import SwiftyStoreKit

struct SubscriptionHelper {
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
  
  static func retrieveInfo(completion: () -> ()) {
    SwiftyStoreKit.retrieveProductsInfo([_currentSubscriptionID]) { result in
      if let product = result.retrievedProducts.first {
        let priceString = product.localizedPrice!
        print("Product: \(product.localizedDescription), price: \(priceString)")
      } else if let invalidProductId = result.invalidProductIDs.first {
        print("Invalid product identifier: \(invalidProductId)")
      } else {
        print("Error: \(result.error)")
      }
    }
  }
}
