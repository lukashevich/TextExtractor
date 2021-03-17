//
//  LibraryViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation

class LibraryViewModel {
  let _documents: [Document] = FileManager.savedDocuments
  var source: [Document] { FileManager.savedDocuments }
  
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
}
