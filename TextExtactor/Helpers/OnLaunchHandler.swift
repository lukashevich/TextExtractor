//
//  OnLaunchHandler.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 28.08.2021.
//

import Foundation

struct OnLaunchHandler {
  
  static var count: Int { UserDefaults.standard.launchCount }
  
  static func handleLaunch() {
    UserDefaults.standard.launchCount += 1
    
    guard UserDefaults.standard.launchCount > 1, PresentationPresenter.presented else {
      PresentationPresenter.startPresentation()
      return
    }
    
    AppStoreReviewHelper.askForReviewIfNeeded()

    switch UserDefaults.standard.launchCount {
      case 3, 5, 13, 21: PresentPaywallOnLaunchHelper.showIfNeeded()
      default: break
    }
  }
}

private extension UserDefaults {
  var launchCount: Int {
    get { UserDefaults.standard.integer(forKey: #function) }
    set { UserDefaults.standard.set(newValue, forKey: #function) }
  }
}
