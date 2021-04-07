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

import MobileCoreServices

extension URL {
  func mimeType() -> String {
    let pathExtension = self.pathExtension
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
      if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
        return mimetype as String
      }
    }
    return "application/octet-stream"
  }
  var containsImage: Bool {
    let mimeType = self.mimeType()
    guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
      return false
    }
    return UTTypeConformsTo(uti, kUTTypeImage)
  }
  var containsAudio: Bool {
    let mimeType = self.mimeType()
    guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
      return false
    }
    return UTTypeConformsTo(uti, kUTTypeAudio)
  }
  var containsVideo: Bool {
    let mimeType = self.mimeType()
    guard  let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() else {
      return false
    }
    return UTTypeConformsTo(uti, kUTTypeMovie)
  }
  
  var type: DocumentSource {
    if containsImage {
      return .picture
    } else if containsAudio {
      return .audio
    } else if containsVideo {
      return .video
    } else {
      return .picture
    }
  }
}
