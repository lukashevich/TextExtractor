//
//  String+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation

extension String {
  func capitalizingFirstLetter() -> String {
    return prefix(1).capitalized + dropFirst()
  }
  
  mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
  
  var fileName: String {
    return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
  }
  
  var fileExtension: String {
    return URL(fileURLWithPath: self).pathExtension
  }
}

let 🇮🇹 = "🇮🇹"
let 🇺🇸 = "🇺🇸"
let 🇩🇪 = "🇩🇪"
let 🇷🇺 = "🇷🇺"
let 🇺🇦 = "🇺🇦"
let 🇪🇸 = "🇪🇸"
