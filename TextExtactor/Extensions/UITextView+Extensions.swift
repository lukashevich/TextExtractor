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
  private var _typingTimer: Timer?
  private var _currentCharacters = [Character]()
  private var _characterIndex = 0
  
  func type(_ text: String) {
    guard !text.isEmpty else { return }

    guard !isTyping else {
      _textQueue.append(text)
      return
    }

    _startTyping(text)
  }

  func completeTyping() {
    _typingTimer?.invalidate()
    _typingTimer = nil

    guard isTyping else { return }

    if _characterIndex < _currentCharacters.count {
      text.append(contentsOf: String(_currentCharacters[_characterIndex...]))
    }
    text.append(contentsOf: _textQueue.joined())
    _resetTypingState()
    scrollToBottom()
  }

  func cancelTyping() {
    _typingTimer?.invalidate()
    _typingTimer = nil
    _resetTypingState()
  }

  private func _startTyping(_ text: String) {
    self.isTyping = true
    _currentCharacters = Array(text)
    _characterIndex = 0
    _typingTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] timer in
      guard let self else {
        timer.invalidate()
        return
      }
      self._typeNextCharacter(using: timer)
    }
  }

  private func _typeNextCharacter(using timer: Timer) {
    guard _characterIndex < _currentCharacters.count else {
      _finishCurrentText(using: timer)
      return
    }

    while _characterIndex < _currentCharacters.count,
          _currentCharacters[_characterIndex] == " " {
      text.append(" ")
      _characterIndex += 1
    }

    guard _characterIndex < _currentCharacters.count else {
      _finishCurrentText(using: timer)
      return
    }

    let character = _currentCharacters[_characterIndex]
    if character != "$" {
      text.append(character)
    }
    _characterIndex += 1
    scrollToBottom()

    if _characterIndex == _currentCharacters.count {
      _finishCurrentText(using: timer)
    }
  }

  private func _finishCurrentText(using timer: Timer) {
    timer.invalidate()
    _typingTimer = nil

    if let nextText = _textQueue.first {
      _textQueue.removeFirst()
      _startTyping(nextText)
    } else {
      _resetTypingState()
    }
  }

  private func _resetTypingState() {
    isTyping = false
    _textQueue.removeAll()
    _currentCharacters.removeAll()
    _characterIndex = 0
  }
}
