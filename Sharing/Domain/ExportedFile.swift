//
//  ExrortedFile.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 25.04.2021.
//

import Foundation

enum ExportedFile: Comparable {
  static func < (lhs: ExportedFile, rhs: ExportedFile) -> Bool {
    switch (lhs, rhs) {
    case (.audio(let lIndex, _), .audio(let rIndex, _)):
      return lIndex < rIndex
    case (.text(let lIndex, _), .text(let rIndex, _)):
      return lIndex < rIndex
    case (.audio(let lIndex, _), .text(let rIndex, _)):
      return lIndex < rIndex
    case (.text(let lIndex, _), .audio(let rIndex, _)):
      return lIndex < rIndex
    }
  }
  
  case audio(index: Int, url: URL)
  case text(index: Int, text: String)
}
