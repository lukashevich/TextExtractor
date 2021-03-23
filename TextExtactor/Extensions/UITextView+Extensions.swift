//
//  UITextView+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit

extension UITextView {
  func scrollToBottom() {
    let textCount: Int = text.count
    guard textCount >= 1 else { return }
    scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
  }
}


class TypenTextView: UITextView {
  var isTyping: Bool = false
  
  private var _textQueue = [String]()
  
  func type(_ text: String) {
    guard !isTyping else {
      return _textQueue.append(text)
    }
    
    self.isTyping = true
    let characterArray = Array(text)
    var characterIndex = 0
    Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { (timer) in
      self.scrollToBottom()
      if characterArray[characterIndex] != "$" {
        while characterArray[characterIndex] == " " {
          self.text.append(" ")
          characterIndex += 1
          if characterIndex == characterArray.count {
            self.isTyping = false
            timer.invalidate()
            return
          }
        }
        self.text.append(characterArray[characterIndex])
      }
      characterIndex += 1
      if characterIndex == characterArray.count {
        self.isTyping = false
        timer.invalidate()
        if let text = self._textQueue.first {
          self._textQueue.removeFirst()
          self.type(text)
        }
      }
    }
  }
}
