//
//  DoublePaywallAnalytics.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 1/12/23.
//

import Foundation

enum DoublePaywallAnalytics: AnalyticEvent {
  var _prefix: String { "paywall" + "_" }
  
  case shown
  case ctaClicked
  case purchaseError
  case purchased
  
  var key: String {
    var key = ""
    switch self {
    case .shown:
      key = "shown"
    case .ctaClicked:
      key = "ctaClicked"
    case .purchased:
      key = "purchased"
    case .purchaseError:
      key = "purchaseError"
    }
    return _prefix.appending(key)
  }
  
  var parameters: Params { nil }
}
