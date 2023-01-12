//
//  AnalyticProvider.swift
//  Ruller
//
//  Created by Oleksandr Lukashevych on 1/10/23.
//

import Foundation
import Amplitude_iOS
import FirebaseCore
import FirebaseAnalytics

enum Provider: CaseIterable {
case amplitude
case firebase
  
  func configure() {
    switch self {
    case .amplitude:
      Amplitude.instance().initializeApiKey("2fb04f55d5af78166ccd9e3115fb0a76")
    case .firebase:
      FirebaseApp.configure()
    }
  }
  
  func log(_ event: AnalyticEvent, with params: AnalyticEvent.Params = nil) {
    switch self {
    case .amplitude:
      Amplitude.instance().logEvent(event.key, withEventProperties: params)
    case .firebase:
      FirebaseAnalytics.Analytics.logEvent(event.key, parameters: params)
    }
  }
  
  func setUserProperty(_ property: [String: Any]) {
    switch self {
    case .amplitude:
      let identity = AMPIdentify()
      
      property.forEach { key, value in
        identity.set(key, value: value as? NSObject)
      }
      Amplitude.instance().identify(identity)
      
    case .firebase: break
      
    }
  }
}
