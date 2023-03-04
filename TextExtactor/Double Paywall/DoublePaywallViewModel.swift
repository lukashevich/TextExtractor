//
//  DoublePaywallViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation

enum PaywallSource: String {
  case main
  case onboarding
  case `extension`  = "extension"
}

typealias DoublePaywallSubscriptions = DoublePaywallViewModel.Subscriptions

struct DoublePaywallViewModel {
    
  typealias Subscriptions = (main: Subscription, secondary: Subscription)
  
  let subscriptions: Subscriptions
  let successHandler: (() -> ())?
  let denyHandler: (() -> ())?
  let source: PaywallSource
  
  init(subscriptions: Subscriptions, handlers: PaywallHandlers?, source: PaywallSource) {
    self.successHandler = handlers?.success
    self.denyHandler = handlers?.deny
    self.subscriptions = subscriptions
    self.source = source
  }
}
