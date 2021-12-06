//
//  Locale+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 19.02.2021.
//

import Foundation

extension Locale {
  var country: String? {
    if let countryStr = localizedString(forLanguageCode: languageCode!) {
      return countryStr.capitalizingFirstLetter()
    } else {
      return regionCode
    }
  }
  
  var countryFlag: String? {
    guard let countryCode = regionCode else { return nil }
    return countryCode
      .unicodeScalars
      .map({ 127397 + $0.value })
      .compactMap(UnicodeScalar.init)
      .map(String.init)
      .joined()
  }
  
  var languageFlag: String? {
    guard let code = languageCode else { return nil }
    
    switch code {
      case "en": return "🇺🇸"
      case "es": return "🇪🇸"
      case "de": return "🇩🇪"
      case "fr": return "🇫🇷"
      case "it": return "🇮🇹"
      case "nl": return "🇳🇱"
      case "pt": return "🇵🇹"
      case "ru": return "🇷🇺"
      case "uk": return "🇺🇦"
      default: return nil
    }
  }
  
  var titleForButton: String {
    switch (languageCode, languageFlag) {
    case (.some(let code), .some(let flag)):
      return "\(flag) \(code)"
    case (.some(let code), .none):
      return "\(code)"
    default:
      return "\(identifier)"
    }
  }
}


