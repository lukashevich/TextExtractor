//
//  AppStoreReviewHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 10.03.2021.
//

import Foundation
import StoreKit

struct AppStoreReviewHelper {
  static func askForReviewIfNeeded() {
    UserDefaults.standard.askReviewAttempts += 1
    
    switch UserDefaults.standard.askReviewAttempts {
    case 3, 12, 20:
      SKStoreReviewController.requestReview()
    default: break
    }
  }
}

private extension UserDefaults {
  var askReviewAttempts: Int {
    get { UserDefaults.standard.integer(forKey: #function) }
    set { UserDefaults.standard.set(newValue, forKey: #function) }
  }
}
