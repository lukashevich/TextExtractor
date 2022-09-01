//
//  Recognizer+Extensions.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 25.04.2021.
//

import Foundation
import Speech

extension Recognizer {
  static func recognizeExported(files: [ExportedFile], in locale:Locale, newText: @escaping ((String) -> ()), completion: (() -> Void)? = nil) {
    var newFiles = files
    guard let file = newFiles.first else {
      return
    }

    switch file {
    case .audio(_, let url):
      Recognizer.recognizeMedia(at: url, in: locale) { text, error in
        newFiles.removeFirst()

        guard let error = error else {
          switch text {
          case .some(let transcribedText) where !transcribedText.isEmpty:
            newText("[AUDIO] - " + transcribedText + "\n")
          default: break
          }
         
          self.recognizeExported(files: newFiles, in: locale, newText: newText)
          return
        }

        guard newFiles.isEmpty else {
          self.recognizeExported(files: newFiles, in: locale, newText: newText)
          return
        }
        
        completion?()
      }
    case .text(_, let text):
      newFiles.removeFirst()
      newText(text)
      self.recognizeExported(files: newFiles, in: locale, newText: newText)
    }
  }
}
