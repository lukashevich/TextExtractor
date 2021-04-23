//
//  PaywallOnLaunchPresentHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 02.04.2021.
//

import UIKit

struct PresentPaywallOnLaunchHelper {
  static func showIfNeeded() {
    UserDefaults.standard.launchCount += 1
    
    switch UserDefaults.standard.launchCount {
    case 2, 5, 10, 12, 14:
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
        if !UserDefaults.standard.userSubscribed {
          UIApplication.rootController?.showPaywall()
        }
      }
    default: break
    }
  }
  
  static func showPaywall(with subscription: Subscription) {
    if !UserDefaults.standard.userSubscribed {
      UIApplication.rootController?.showPaywall(subscription: subscription)
    }
  }
}

private extension UserDefaults {
  var launchCount: Int {
    get { UserDefaults.standard.integer(forKey: #function) }
    set { UserDefaults.standard.set(newValue, forKey: #function) }
  }
}