//
//  LibraryItemCellViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation

enum LibraryDocumentBadge: Equatable {
  case none
  case new
  case updated

  var title: String {
    switch self {
    case .none: return ""
    case .new: return "New"
    case .updated: return "Updated"
    }
  }
}

struct LibraryItemCellViewModel {
  let document: Document
  let badge: LibraryDocumentBadge
}
