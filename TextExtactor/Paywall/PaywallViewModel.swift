//
//  PaywallViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation
struct PaywallHandlers {
  let success: (() -> ())?
  let deny: (() -> ())?
  
  static var empty: PaywallHandlers {
    return PaywallHandlers(success: nil, deny: nil)
  }
}

struct PaywallViewModel {
  let subscription: Subscription
  let successHandler: (() -> ())?
  let denyHandler: (() -> ())?
  let source: PaywallSource

  init(subscription: Subscription, handlers: PaywallHandlers?, source: PaywallSource) {
    self.successHandler = handlers?.success
    self.denyHandler = handlers?.deny
    self.subscription = subscription
    self.source = source
  }
}
