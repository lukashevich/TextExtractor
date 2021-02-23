//
//  AudioChunk.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation

struct AudioChunk {
  let start: Int
  let duration: Int
  
  func copy(with newStart: Int) -> AudioChunk {
    return AudioChunk(start: newStart, duration: duration)
  }
}
