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
}

struct PaywallViewModel {
  let successHandler: (() -> ())?
  let denyHandler: (() -> ())?
  
  init(handlers: PaywallHandlers?) {
    self.successHandler = handlers?.success
    self.denyHandler = handlers?.deny
  }
}
