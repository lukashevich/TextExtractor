//
//  ExportedDocPreviewViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 06.04.2021.
//

import UIKit

enum HeaderOption: Int, Codable {
  case verticalTitle
  case horizontalTitle
  case verticalDate
  case horizontalDate
}

struct ExportedDocPreviewViewModel {
  
  enum TextStyle {
    case bold
    case `default`
    case light
  }
  
  var dateStyleUpdated: ((DateFormatter.Style) -> Void)?
  var headerStyleUpdated: ((HeaderOption) -> Void)?
  
  var dateStyle: DateFormatter.Style = .medium {
    didSet {
      dateStyleUpdated?(dateStyle)
    }
  }
  
  var headerStyle: HeaderOption = .verticalTitle {
    didSet {
      headerStyleUpdated?(headerStyle)
    }
  }
}

extension DateFormatter.Style: Codable {}

struct DocumentStyle: Codable {
  let headerStyle: HeaderOption
  let dateStyle: DateFormatter.Style
  
  func copy(header: HeaderOption? = nil, date: DateFormatter.Style? = nil) -> DocumentStyle {
    DocumentStyle(headerStyle: header ?? self.headerStyle, dateStyle: date ?? self.dateStyle)
  }
}


