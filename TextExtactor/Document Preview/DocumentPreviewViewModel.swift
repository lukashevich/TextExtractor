//
//   DocumentPreviewViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import Foundation

enum PreviewOpenType {
  case mediaDoc(Document)
  case textDoc(Document)
}
struct DocumentPreviewViewModel {
  var document: Document
  let isNew: Bool
}
