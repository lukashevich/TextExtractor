//
//  FileManager+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 21.02.2021.
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
  
  static func removeDocument(_ doc: Document) {
    let fileManager = FileManager.default
    do {
      try fileManager.removeItem(atPath: documentsFolder.path + "/" + doc.name)
    } catch {
      print("Could not remove doc: \(error)")
    }
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
  
  static func isDocumentExist(_ doc: Document) -> Bool {
    let documentsContent = FileManager.content(from: documentsFolder) ?? []
    return documentsContent.contains(doc.name)
  }
  
  static func createFolder(for doc: Document, completion: (URL) -> Void) {
    let dataPath = documentsFolder.appendingPathComponent(doc.name)
    if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
      do {
        print(dataPath.absoluteString)
        try FileManager.default.createDirectory(at: dataPath, withIntermediateDirectories: false, attributes: nil)
        completion(dataPath)
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  static private var documentsFolders: [URL] {
    do {
      return try FileManager.default.contentsOfDirectory(at: documentsFolder, includingPropertiesForKeys: nil)
        .filter { $0.lastPathComponent != tmpFolderName }
    } catch {
      return []
    }
  }
  
  static var savedDocuments: [Document] {
    do {
      let fileNames = documentsFolders
      return fileNames
        .map { $0.appendingPathComponent(metaFileName) }
        .compactMap { (url) -> [String: String]? in
          do {
            let data = try Data(contentsOf: url, options: [])
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
          } catch {
            return nil
          }
      }.map(Document.init)
    }
  }
}
