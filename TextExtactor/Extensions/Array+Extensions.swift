//
//  Array+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 09.04.2021.
//

import Foundation

extension Sequence {
  func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
    return Dictionary(grouping: self, by: key)
  }
  
  func groupToOne<Key: Hashable, Value>(by keyValueSelector: @escaping (Iterator.Element) -> (Key, Value)?) -> [Key: Value] {
    var dict = Dictionary<Key, Value>()
    self.forEach { element in
      guard let (key, value) = keyValueSelector(element) else { return }
      dict[key] = value
    }
    return dict
  }
  
  func groupToOne<Key: Hashable>(by keySelector: @escaping (Iterator.Element) -> Key?) -> [Key: Iterator.Element] {
    return groupToOne { element in
      keySelector(element)
        .map { key in (key, element) } }
  }
}
