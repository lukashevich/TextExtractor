//
//  DoublePaywallViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation

typealias DoublePaywallSubscriptions = DoublePaywallViewModel.Subscriptions

struct DoublePaywallViewModel {
  
  enum Source {
    case main
    case `extension`
  }
  
  typealias Subscriptions = (main: Subscription, secondary: Subscription)
  
  let subscriptions: Subscriptions
  let successHandler: (() -> ())?
  let denyHandler: (() -> ())?
  let source: Source
  
  init(subscriptions: Subscriptions, handlers: PaywallHandlers?, source: Source) {
    self.successHandler = handlers?.success
    self.denyHandler = handlers?.deny
    self.subscriptions = subscriptions
    self.source = source
  }
}
