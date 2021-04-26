//
//  FileManager+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.04.2021.
//

import Foundation

let tmpFolderName = "TMP"
let metaFileName = "meta"

extension FileManager {
  
  
  static var documentsFolder: URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
  
  static var tmpFolder: URL {
    return documentsFolder.appendingPathComponent(tmpFolderName)
  }
  
  static func createDefaults() {
    let tmpFolderPath = documentsFolder.appendingPathComponent(tmpFolderName)
    if !FileManager.default.fileExists(atPath: tmpFolderPath.absoluteString) {
      do {
        try FileManager.default.createDirectory(at: tmpFolderPath, withIntermediateDirectories: false, attributes: nil)
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  static func content(from url: URL) -> [String]? {
    let fileManager = FileManager.default
    let filePaths = try? fileManager.contentsOfDirectory(atPath: url.path)
    return filePaths
  }
  
  static func clearTmpFolder() {
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: tmpFolder.path)
      for filePath in filePaths {
        try fileManager.removeItem(atPath: tmpFolder.path + "/" + filePath)
      }
    } catch {
      print("Could not clear temp folder: \(error)")
    }
  }
  
  static func clearDocFolder() {
    let fileManager = FileManager.default
    do {
      let filePaths = try fileManager.contentsOfDirectory(atPath: documentsFolder.path)
      for filePath in filePaths {
        try fileManager.removeItem(atPath: documentsFolder.path + "/" + filePath)
      }
    } catch {
      print("Could not clear doc folder: \(error)")
    }
  }
}
