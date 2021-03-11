//
//  URL+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 11.03.2021.
//

import Foundation

extension URL {
  var size: String {
    ByteCountFormatter.string(fromByteCount: _fileSize, countStyle: .file)
  }
  
  private var _fileSize: Int64 {
    var fileSize: Double = 0.0
    var fileSizeValue = 0.0
    try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
    if fileSizeValue > 0.0 {
      fileSize = (Double(fileSizeValue) / (1024 * 1024))
    }
    return Int64(fileSize)
  }
}
