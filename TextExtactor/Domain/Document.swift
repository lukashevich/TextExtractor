//
//  Document.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit
import PDFKit
import AVFoundation

enum DocumentSaveError: LocalizedError {
  case nameAlreadyExists
  case missingAudio
  case incompleteWrite

  var errorDescription: String? {
    switch self {
    case .nameAlreadyExists:
      return "A document with this name already exists."
    case .missingAudio:
      return "The audio file is unavailable, so the document was not changed."
    case .incompleteWrite:
      return "The document could not be saved safely. Your existing document is unchanged."
    }
  }
}

extension Document {
  
  var pdfLink: URL {
    let url = URL(fileURLWithPath: FileManager.documentsFolder.appendingPathComponent(name).path)
    return url.appendingPathComponent(name).appendingPathExtension("pdf")
  }
  
  var audioLink: URL {
    let url = URL(fileURLWithPath: FileManager.documentsFolder.appendingPathComponent(name).path)
    
    return url.appendingPathComponent("audio").appendingPathExtension("m4a")
  }

  var timelineLink: URL {
    let url = URL(fileURLWithPath: FileManager.documentsFolder.appendingPathComponent(name).path)
    return url.appendingPathComponent("timeline").appendingPathExtension("json")
  }

  var timeline: [TranscriptTimelineItem] {
    guard let data = try? Data(contentsOf: timelineLink) else { return [] }
    return (try? JSONDecoder().decode([TranscriptTimelineItem].self, from: data)) ?? []
  }
  
  var pdfSize: String { pdfLink.size }
  var audioSize: String { audioLink.size }

  var image: UIImage? {
    // Instantiate a `CGPDFDocument` from the PDF file's URL.
    guard let document = PDFDocument(url: pdfLink) else { return nil }

    // Get the first page of the PDF document.
    guard let page = document.page(at: 0) else { return nil }

    // Fetch the page rect for the page we want to render.
    let pageRect = page.bounds(for: .mediaBox)

    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
    return renderer.image { ctx in
        // Set and fill the background color.
        UIColor.white.set()
        ctx.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: pageRect.height))

        // Translate the context so that we only draw the `cropRect`.
        ctx.cgContext.translateBy(x: -pageRect.origin.x, y: pageRect.size.height - pageRect.origin.y)

        // Flip the context vertically because the Core Graphics coordinate system starts from the bottom.
        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

        // Draw the PDF page.
        page.draw(with: .mediaBox, to: ctx.cgContext)
    }
  }
  
  func isEqual(_ doc: Document) -> Bool {
    return name == doc.name && text == doc.text
  }

  func copy(name: String? = nil, text: String? = nil) -> Document {
    return Document(name: name ?? self.name, text: text ?? self.text, createdAt: createdAt, modifiedAt: Date(), source: self.source)
  }
  
  init(meta: [String: String]) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

    self.name = meta["name"] ?? ""
    self.text = meta["text"] ?? ""
    self.createdAt = dateFormatter.date(from: meta["createdAt"]  ?? "") ?? Date()
    self.modifiedAt = dateFormatter.date(from: meta["modifiedAt"] ?? "") ?? Date()
    self.source = DocumentSource(rawValue: meta["source"] ?? "") ?? .picture
  }
}

extension Document {
  private var _meta: [String: String] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    return [
      "name": name,
      "text": text,
      "source": source.rawValue,
      "createdAt": dateFormatter.string(from: createdAt),
      "modifiedAt": dateFormatter.string(from: modifiedAt)
    ]
  }
  private func _createMetaFile(to url: URL) {
    do {
      let data = try JSONSerialization.data(withJSONObject: _meta, options: [])
      try data.write(to: url.appendingPathComponent("meta"), options: [])
    } catch {
      print(error)
    }
  }
  
  private func _moveAudio(to url: URL) {
    AudioEditHelper.moveTempAudioFile(to: url.appendingPathComponent("audio").appendingPathExtension("m4a"))
  }

  private func _createTimelineFile(_ timeline: [TranscriptTimelineItem], to url: URL) {
    guard !timeline.isEmpty else { return }

    do {
      let data = try JSONEncoder().encode(timeline)
      try data.write(to: url.appendingPathComponent("timeline").appendingPathExtension("json"), options: .atomic)
    } catch {
      print("Could not save timeline: \(error)")
    }
  }

  private func _writeMetaFile(to directory: URL) throws {
    let data = try JSONSerialization.data(withJSONObject: _meta, options: [])
    try data.write(to: directory.appendingPathComponent(metaFileName), options: .atomic)
  }

  private func _writeTimelineFile(_ timeline: [TranscriptTimelineItem], to directory: URL) throws {
    guard !timeline.isEmpty else { return }
    let data = try JSONEncoder().encode(timeline)
    try data.write(
      to: directory.appendingPathComponent("timeline").appendingPathExtension("json"),
      options: .atomic
    )
  }

  func saveReplacing(
    _ previousDocument: Document?,
    audioSourceURL: URL?,
    timeline: [TranscriptTimelineItem]
  ) throws {
    let fileManager = FileManager.default
    let destination = FileManager.documentsFolder.appendingPathComponent(name)
    let previousURL = previousDocument.map { FileManager.documentsFolder.appendingPathComponent($0.name) }

    if fileManager.fileExists(atPath: destination.path), previousURL?.path != destination.path {
      throw DocumentSaveError.nameAlreadyExists
    }

    let stagingURL = FileManager.documentsFolder
      .appendingPathComponent(".document-stage-\(UUID().uuidString)")

    do {
      try fileManager.createDirectory(at: stagingURL, withIntermediateDirectories: false)
      try PDFCreator.createPDF(for: self, in: stagingURL)
      try _writeMetaFile(to: stagingURL)
      try _writeTimelineFile(timeline, to: stagingURL)

      if source == .audio || source == .video {
        guard let audioSourceURL,
              fileManager.fileExists(atPath: audioSourceURL.path)
        else {
          throw DocumentSaveError.missingAudio
        }
        try fileManager.copyItem(
          at: audioSourceURL,
          to: stagingURL.appendingPathComponent("audio").appendingPathExtension("m4a")
        )
      }

      guard fileManager.fileExists(atPath: stagingURL.appendingPathComponent(metaFileName).path),
            fileManager.fileExists(atPath: stagingURL.appendingPathComponent(name).appendingPathExtension("pdf").path)
      else {
        throw DocumentSaveError.incompleteWrite
      }

      if source == .audio || source == .video,
         !fileManager.fileExists(atPath: stagingURL.appendingPathComponent("audio").appendingPathExtension("m4a").path) {
        throw DocumentSaveError.incompleteWrite
      }

      try _commit(stagingURL, to: destination, replacing: previousURL)
    } catch {
      try? fileManager.removeItem(at: stagingURL)
      throw error
    }
  }

  private func _commit(_ stagingURL: URL, to destination: URL, replacing previousURL: URL?) throws {
    let fileManager = FileManager.default

    if fileManager.fileExists(atPath: destination.path) {
      let backupURL = FileManager.documentsFolder
        .appendingPathComponent(".document-backup-\(UUID().uuidString)")
      try fileManager.moveItem(at: destination, to: backupURL)

      do {
        try fileManager.moveItem(at: stagingURL, to: destination)
      } catch {
        try? fileManager.moveItem(at: backupURL, to: destination)
        throw error
      }

      try? fileManager.removeItem(at: backupURL)
      return
    }

    try fileManager.moveItem(at: stagingURL, to: destination)

    guard let previousURL, previousURL.path != destination.path,
          fileManager.fileExists(atPath: previousURL.path)
    else {
      return
    }
    try? fileManager.removeItem(at: previousURL)
  }
  
  func createFile(timeline: [TranscriptTimelineItem] = []) {
    guard !FileManager.isDocumentExist(self) else {
      self.copy(name: name.incremented).createFile(timeline: timeline)
      return
    }
      
    FileManager.createFolder(for: self) { url in
      PDFCreator.createPDF(for: self)
      self._moveAudio(to: url)
      self._createTimelineFile(timeline, to: url)
      self._createMetaFile(to: url)
    }
  }
}

extension String {
  var incremented: String {
    return self + " (copy)"
  }
  
  static var newIncrementedName: String {
    let docNames = FileManager.savedDocuments.map(\.name)
    return String(format: "New %i", docNames.count)
  }
}
