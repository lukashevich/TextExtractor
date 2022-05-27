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
    set {
      UserDefaults(suiteName: Constant.groupID)!.set(newValue.identifier, forKey: #function)
      UserDefaults.standard.set(newValue.identifier, forKey: #function)
    }
  }
  
  func setDefaults() {
    extractingLocale = Locale.current
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
    get {
      UserDefaults.standard.bool(forKey: #function) ||
        UserDefaults(suiteName: Constant.groupID)!.bool(forKey: #function) || userPromoted
    }
    set {
      UserDefaults.standard.set(newValue, forKey: #function)
      UserDefaults(suiteName: Constant.groupID)!.set(newValue, forKey: #function)
    }
  }
  
  var convertationDate: Date {
    get { Date(timeIntervalSince1970: TimeInterval(UserDefaults.standard.integer(forKey: #function))) }
    set { UserDefaults.standard.set(convertationDate.timeIntervalSince1970, forKey: #function) }
  }
  
  var documentStyle: DocumentStyle {
    get {
      if let styleData = UserDefaults.standard.object(forKey: #function) as? Data {
        if let style = try? JSONDecoder().decode(DocumentStyle.self, from: styleData) {
          return style
        }
      }
      return DocumentStyle(headerStyle: .verticalTitle, dateStyle: .medium)
    }
    set {
      if let encoded = try? JSONEncoder().encode(newValue) {
        UserDefaults.standard.set(encoded, forKey: #function)
      }
    }
  }
}

//SHARING
extension UserDefaults {
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
