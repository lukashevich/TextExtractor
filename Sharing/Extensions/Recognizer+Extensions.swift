//
//  Recognizer+Extensions.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 25.04.2021.
//

import Foundation
import Speech

extension Recognizer {
  static func recognizeExported(files: [ExportedFile], in locale:Locale, newText: @escaping ((String) -> ()), completion: ((String) -> ())? = nil) {
    var newFiles = files
    guard let file = newFiles.first else {
      return
    }

    switch file {
    case .audio(_, let url):
      Recognizer.recognizeMedia(at: url, in: locale) { text in
        newFiles.removeFirst()
        if !text.isEmpty {
          newText("[AUDIO] - " + text + "\n")
        }
        self.recognizeExported(files: newFiles, in: locale, newText: newText)
      }
    case .text(_, let text):
      newFiles.removeFirst()
      newText(text)
      self.recognizeExported(files: newFiles, in: locale, newText: newText)
    }
  }
}
