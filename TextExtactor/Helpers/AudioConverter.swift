//
//  AudioConverter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.04.2021.
//

import Foundation

struct AudioConverter {
  
  static func convertOGG(at: URL) -> URL {
    let dstURL = FileManager.tmpFolder.appendingPathComponent("audio_ogg").appendingPathExtension("ogg")
    try? FileManager.default.removeItem(atPath: dstURL.path)
    try? FileManager.default.copyItem(at: at, to: dstURL)
    
    let newPath = FileManager.tmpFolder.appendingPathComponent("audio_ogg").appendingPathExtension("mp4")
    MobileFFmpeg.execute("-i \(dstURL) -c:v mpeg4 \(newPath)")
    return newPath
  }
  
  static func convertOGG(at url: URL, with index: Int) -> URL {
    let dstURL = FileManager.tmpFolder.appendingPathComponent("audio_ogg_\(index)").appendingPathExtension("ogg")
    try? FileManager.default.removeItem(atPath: dstURL.path)
    try? FileManager.default.copyItem(at: url, to: dstURL)
    
    let newPath = FileManager.tmpFolder.appendingPathComponent("audio_ogg_\(index)").appendingPathExtension("mp4")
    MobileFFmpeg.execute("-i \(dstURL) -c:v mpeg4 \(newPath)")
    return newPath
  }
  
  static func convertOGGs(at urls: [URL]) -> [URL] {
    var result = [URL]()
    urls.enumerated().forEach { (index, url) in
      let dstURL = FileManager.tmpFolder.appendingPathComponent("audio_ogg_\(index)").appendingPathExtension("ogg")
      try? FileManager.default.removeItem(atPath: dstURL.path)
      try? FileManager.default.copyItem(at: url, to: dstURL)
      
      let newPath = FileManager.tmpFolder.appendingPathComponent("audio_ogg_\(index)").appendingPathExtension("mp4")
      result.append(newPath)
      MobileFFmpeg.execute("-i \(dstURL) -c:v mpeg4 \(newPath)")
    }
    
    return result
  }
}
