//
//  Analytics.swift
//  Ruller
//
//  Created by Oleksandr Lukashevych on 10.02.2022.
//

import Foundation

protocol AnalyticEvent {
  typealias Params = [String: Any]?
  var _prefix: String { get }
  var key: String { get }
  var parameters: Params { get }
}

struct Analytics {
  
  enum UserProperty {
    case transcriptionsCount(Int)
    case extractionLocale(String)
    case subscribed(Bool)
    
    var key: String {
      switch self {
      case .transcriptionsCount: return "transcriptionsCount"
      case .extractionLocale: return "extractionLocale"
      case .subscribed: return "subscribed"
      }
    }
  }
  
  static private let _providers = Provider.allCases
 
  static func configure() {
    _providers.forEach{ $0.configure() }
  }
  
  static func log(_ event: AnalyticEvent, with params: AnalyticEvent.Params = nil) {
    for provider in _providers {
      provider.log(event, with: params != nil ? params : event.parameters)
    }
  }
  
  static func setUser(property: UserProperty) {
    for provider in _providers {
      switch property {
      case .transcriptionsCount(let value):
        provider.setUserProperty([property.key: value])
      case .extractionLocale(let value):
        provider.setUserProperty([property.key: value])
      case .subscribed(let value):
        provider.setUserProperty([property.key: value])
      }
    }
  }
}
