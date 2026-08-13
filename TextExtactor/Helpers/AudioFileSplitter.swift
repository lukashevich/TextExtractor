//
//  AudioFileSplitter.swift
//  TextExtactor
//

import Foundation

// Kept as a compatibility wrapper for older call sites. Segmentation now happens
// in AudioEditHelper after the source audio has been normalized.
struct AudioFileSplitter {
  static func split(file at: URL, completion: @escaping ([URL]) -> Void) {
    AudioEditHelper.prepareFile(at: at) { urls, _ in
      completion(urls)
    }
  }
}
