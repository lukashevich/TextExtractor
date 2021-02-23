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
}
