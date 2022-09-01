//
//  PaywallOnLaunchPresentHelper.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 02.04.2021.
//

import UIKit

struct PresentPaywallOnLaunchHelper {
  static func showIfNeeded() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
      if !UserDefaults.standard.userSubscribed {
          UIApplication.rootController?.showDoublePaywall(with: Subscription.currentDoubleGroup)
//        UIApplication.rootController?.showPaywall()
      }
    }
  }
  
  static func showPaywall(with subscription: Subscription) {
    if !UserDefaults.standard.userSubscribed {
      UIApplication.rootController?.showPaywall(with: subscription)
    }
  }
  
  static func showDoublePaywall(with subscriptions: DoublePaywallSubscriptions) {
    if !UserDefaults.standard.userSubscribed {
      UIApplication.rootController?.showDoublePaywall(with: subscriptions)
    }
  }
}
