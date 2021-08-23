//
//  UserDefaults+Extensions.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 25.04.2021.
//

import Foundation
extension UserDefaults {
  var extractingLocale: Locale {
    get {
      Locale(identifier: UserDefaults(suiteName: Constant.groupID)!.string(forKey: #function) ?? Locale.current.identifier)
    }
    set {
      UserDefaults.standard.set(newValue.identifier, forKey: #function)
      UserDefaults(suiteName: Constant.groupID)!.set(newValue.identifier, forKey: #function)
    }
  }
  
  var documentsToImport: [Document] {
    get {
      if let styleData = UserDefaults(suiteName: Constant.groupID)!.object(forKey: #function) as? Data {
        if let style = try? JSONDecoder().decode([Document].self, from: styleData) {
          return style
        }
      }
      return []
    }
    set {
      if let encoded = try? JSONEncoder().encode(newValue) {
        UserDefaults(suiteName: Constant.groupID)!.set(encoded, forKey: #function)
      }
    }
  }
}
