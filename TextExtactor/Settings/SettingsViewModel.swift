//
//  SettingsViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import Foundation

struct SettingsViewModel {
  
  enum Identifier: String {
    case subscription = "subscription"
    case restore = "restore"
    case privacy = "privacy"
    case document = "document"
    case audio = "audio"
    case tos = "tos"
    case feedback = "feedback"
    case howToUse = "how_to_use"
  }
  
  var updateContent: (() -> Void)?
  
  var source: [[Identifier]] {
    switch UserDefaults.standard.userSubscribed {
    case true:
      return [
        [.restore],
        [.document, .audio],
        [.howToUse],
        [.privacy, .tos]
      ]
    case false:
      return [
        [.subscription],
        [.document, .audio],
        [.howToUse],
        [.privacy, .tos]
      ]
    }
  }
  
  func subscribed() {
    UserDefaults.standard.userSubscribed = true
    self.updateContent?()
  }
}
