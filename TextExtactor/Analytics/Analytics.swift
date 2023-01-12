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
    var key: String { "" }
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
//    for provider in _providers {
//      switch property {
//      case .measureColor(let value),
//          .measureUnit(let value):
//        provider.setUserProperty([property.key: value])
//      case .measuresCount(let value):
//        provider.setUserProperty([property.key: value])
//      case .isPremium(let value):
//        provider.setUserProperty([property.key: value])
//      }
//    }
  }
}
