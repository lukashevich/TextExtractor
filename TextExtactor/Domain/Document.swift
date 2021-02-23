//
//  Document.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit
import PDFKit

struct Document {
  let name: String
  let text: String
  let createdAt: Date
  let modifiedAt: Date
  
  var pdfLink: URL {
    let url = URL(fileURLWithPath: FileManager.documentsFolder.appendingPathComponent(name).path)
    return url.appendingPathComponent(name).appendingPathExtension("pdf")
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
  
  init(name: String, text: String, createdAt: Date, modifiedAt: Date) {
    self.name = name
    self.text = text
    self.createdAt = createdAt
    self.modifiedAt = modifiedAt
  }
  
  func isEqual(_ doc: Document) -> Bool {
    return name == doc.name && text == doc.text
  }

  func copy(name: String? = nil, text: String? = nil) -> Document {
    return Document(name: name ?? self.name, text: text ?? self.text, createdAt: createdAt, modifiedAt: Date())
  }
  
  init(meta: [String: String]) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

    self.name = meta["name"] ?? ""
    self.text = meta["text"] ?? ""
    self.createdAt = dateFormatter.date(from: meta["createdAt"]  ?? "") ?? Date()
    self.modifiedAt = dateFormatter.date(from: meta["modifiedAt"] ?? "") ?? Date()
  }
}

extension Document {
  private var _meta: [String: String] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    return [
      "name": name,
      "text": text,
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
  
  func createFile() {
    guard !FileManager.isDocumentExist(self) else {
      self.copy(name: name.incremented).createFile()
      return
    }
    
    FileManager.createFolder(for: self) { url in
      PDFCreator.createPDF(for: self)
      self._createMetaFile(to: url)
    }
  }
}

extension String {
  var incremented: String {
    return self + " (copy)"
  }
}
