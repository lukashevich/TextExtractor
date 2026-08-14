//
//  LibraryViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation

class LibraryViewModel {
  let _documents: [Document] = FileManager.savedDocuments
  var source: [Document] { FileManager.savedDocuments.sorted(by: { $0.createdAt > $1.createdAt }) }
  
  func sortDocuments(_ sort: LibraryHeader.Sort) -> [Document] {
    switch sort {
    case .recent:
      return source.sorted(by: { $0.createdAt > $1.createdAt })
    case .title:
      return source.sorted(by: { $0.name > $1.name })
    case .modified:
      return source.sorted(by: { $0.modifiedAt > $1.modifiedAt })
    }
  }

  func badge(for document: Document) -> LibraryDocumentBadge {
    let calendar = Calendar.current
    let newestDocument = source.max(by: { $0.createdAt < $1.createdAt })

    if newestDocument?.name == document.name,
       calendar.isDateInToday(document.createdAt) {
      return .new
    }

    if document.modifiedAt > document.createdAt,
       calendar.isDateInToday(document.modifiedAt) {
      return .updated
    }

    return .none
  }
}
