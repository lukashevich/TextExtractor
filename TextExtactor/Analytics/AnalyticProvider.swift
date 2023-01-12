//
//  AnalyticProvider.swift
//  Ruller
//
//  Created by Oleksandr Lukashevych on 1/10/23.
//

import Foundation
import FirebaseCore
import FirebaseAnalytics

enum Provider: CaseIterable {
  case firebase
  
  func configure() {
    switch self {
    case .firebase:
      FirebaseApp.configure()
    }
  }
  
  func log(_ event: AnalyticEvent, with params: AnalyticEvent.Params = nil) {
    switch self {
    case .firebase:
      FirebaseAnalytics.Analytics.logEvent(event.key, parameters: params)
    }
  }
  
  func setUserProperty(_ property: [String: Any]) {
    switch self {
    case .firebase: break
    }
  }
}
