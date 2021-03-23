//
//  UserDefaults+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.02.2021.
//

import Foundation

extension UserDefaults {
  
  var shouldShowPaywall: Bool {
    !userSubscribed && FileManager.savedDocuments.count >= documentsLimit
  }
  
  var documentsLimit: Int { 3 }
  
  var extractingLocale: Locale {
    get {
      Locale(identifier: UserDefaults.standard.string(forKey: #function) ?? Locale.current.identifier)
    }
    set { UserDefaults.standard.set(newValue.identifier, forKey: #function) }
  }
  
  func setDefaults() {
    extractingLocale = Locale.current
  }
  
  var userSubscribed: Bool {
    get {
      true
//      UserDefaults.standard.bool(forKey: #function)
      
    }
    set { UserDefaults.standard.set(newValue, forKey: #function) }
  }
}
