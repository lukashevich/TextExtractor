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

extension Document {
  
  var pdfLink: URL {
    let url = URL(fileURLWithPath: FileManager.documentsFolder.appendingPathComponent(name).path)
    return url.appendingPathComponent(name).appendingPathExtension("pdf")
  }
  
  var audioLink: URL {
    let url = URL(fileURLWithPath: FileManager.documentsFolder.appendingPathComponent(name).path)
    
    return url.appendingPathComponent("audio").appendingPathExtension("m4a")
  }
  
  var pdfSize: String { pdfLink.size }
  var audioSize: String { audioLink.size }

  var isNew: Bool {
    Calendar.current.isDateInYesterday(modifiedAt) || Calendar.current.isDateInToday(modifiedAt)
  }
  
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
  
  func createFile() {
    guard !FileManager.isDocumentExist(self) else {
      self.copy(name: name.incremented).createFile()
      return
    }
      
    FileManager.createFolder(for: self) { url in
      PDFCreator.createPDF(for: self)
      self._moveAudio(to: url)
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
