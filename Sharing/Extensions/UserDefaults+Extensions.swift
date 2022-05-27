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
  
  var convertationDate: Date {
    get { Date(timeIntervalSince1970: TimeInterval(UserDefaults.standard.integer(forKey: #function))) }
    set { UserDefaults.standard.set(convertationDate.timeIntervalSince1970, forKey: #function) }
  }
  
  var userPromoted: Bool {
    get {
      UserDefaults.standard.bool(forKey: #function) ||
        UserDefaults(suiteName: Constant.groupID)!.bool(forKey: #function)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
      UserDefaults(suiteName: Constant.groupID)!.set(newValue, forKey: #function)
    }
  }
  
  var userSubscribed: Bool {
    get { UserDefaults(suiteName: Constant.groupID)!.bool(forKey: #function) }
    set { UserDefaults(suiteName: Constant.groupID)!.set(newValue, forKey: #function) }
  }
  
  var transcriptionsCount: Int {
    get { UserDefaults.standard.integer(forKey: #function) }
    set { UserDefaults.standard.set(newValue, forKey: #function) }
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
