//
//  PDFCreator.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 17.02.2021.
//

import Foundation
import PDFKit

struct PDFCreator {
  static func createPDF(for doc: Document) {
    let format = UIGraphicsPDFRendererFormat()
    let metaData = [
      kCGPDFContextTitle: doc.name,
      kCGPDFContextAuthor: "Me"
    ]
    format.documentInfo = metaData as [String: Any]
    
    let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect,
                                         format: format)
    
    let data = renderer.pdfData { (context) in
      context.beginPage()
      
      let paragraphStyle = NSMutableParagraphStyle()
      let attributes = [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12),
        NSAttributedString.Key.paragraphStyle: paragraphStyle
      ]
      
      let titleRect = CGRect(x: 20,
                            y: 20, // top margin
                            width: pageRect.width - 80,
                            height: 60)

      doc.name.draw(in: titleRect, withAttributes: attributes)
      
      let textRect = CGRect(x: 20,
                            y: 100, // top margin
                            width: pageRect.width - 40,
                            height: pageRect.height - 200)

      doc.text.draw(in: textRect, withAttributes: attributes)
    }
        
    let docURL = FileManager.documentsFolder
    let dataPath = docURL.appendingPathComponent(doc.name)
    PDFDocument(data: data)?.write(to: dataPath.appendingPathComponent(doc.name).appendingPathExtension("pdf"))
  }
}
