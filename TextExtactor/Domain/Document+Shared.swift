//
//  Document+Shared.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 25.04.2021.
//

import Foundation

enum DocumentSource: String, Codable {
  case video
  case audio
  case picture
}

struct Document: Codable {
  let name: String
  let text: String
  let createdAt: Date
  let modifiedAt: Date
  let source: DocumentSource
  
  init(name: String, text: String, createdAt: Date, modifiedAt: Date, source: DocumentSource) {
    self.name = name
    self.text = text
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
    self.source = source
  }
}

