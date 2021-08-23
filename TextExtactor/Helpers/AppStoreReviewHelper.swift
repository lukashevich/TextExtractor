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
    
    guard UserDefaults.standard.userSubscribed,
          UserDefaults.standard.convertationDate.timeIntervalSince1970 > 0,
          Date() > UserDefaults.standard.convertationDate else {
      return
    }
    
    UserDefaults.standard.askReviewAttempts += 1
    
    switch UserDefaults.standard.askReviewAttempts {
    case 2, 5, 12, 20:
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
