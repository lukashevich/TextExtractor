//
//  PDFCreator.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 17.02.2021.
//

import Foundation
import PDFKit

private let _pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)

struct PDFCreator {
  static func createPDF(for doc: Document) {
    let format = UIGraphicsPDFRendererFormat()
    let metaData = [
      kCGPDFContextTitle: doc.name,
      kCGPDFContextAuthor: "Me"
    ]
    format.documentInfo = metaData as [String: Any]
    
    let renderer = UIGraphicsPDFRenderer(bounds: _pageRect,
                                         format: format)
    
    let data = renderer.pdfData { (context) in
      self.drawDoc(doc, context: context)
    }
    
    let docURL = FileManager.documentsFolder
    let dataPath = docURL.appendingPathComponent(doc.name)
    
    try? FileManager.default.removeItem(at: dataPath.appendingPathComponent(doc.name).appendingPathExtension("pdf"))
    PDFDocument(data: data)?.write(to: dataPath.appendingPathComponent(doc.name).appendingPathExtension("pdf"))
  }
  
  @discardableResult
  static func drawDoc(_ doc : Document, context : UIGraphicsPDFRendererContext) -> CGFloat {
    
    let docStyle = UserDefaults.standard.documentStyle
    let attributes = docStyle.headerStyle.attributes
    
    //4
    let currentText = CFAttributedStringCreate(nil,
                                               doc.text as CFString,
                                               attributes.text as CFDictionary)
    //5
    let framesetter = CTFramesetterCreateWithAttributedString(currentText!)
    
    //6
    var currentRange = CFRangeMake(0, 0)
    var currentPage = 0
    var done = false
    repeat {
      
      //7
      /* Mark the beginning of a new page.*/
      context.beginPage()
      
      //8
      /*Draw a page number at the bottom of each page.*/
      currentPage += 1
      
      switch currentPage {
      case 1:
        let docStyle = UserDefaults.standard.documentStyle
        let frames = docStyle.headerStyle.getContentFrames
        let attributes = docStyle.headerStyle.attributes

        let formatter = DateFormatter()
        formatter.dateStyle = docStyle.dateStyle
        let dateString = formatter.string(from: doc.createdAt)
        doc.name.draw(in: frames.title, withAttributes: attributes.title)
        dateString.draw(in: frames.date, withAttributes: attributes.date)
        
        currentRange = renderFirstPage(doc: doc,
                                       withTextRange: currentRange,
                                       andFramesetter: framesetter)
      default:
        currentRange = renderPage(currentPage,
                                  withTextRange: currentRange,
                                  andFramesetter: framesetter)
      }
      
      //10
      /* If we're at the end of the text, exit the loop. */
      if currentRange.location == CFAttributedStringGetLength(currentText) {
        done = true
      }
      
    } while !done
    
    return CGFloat(currentRange.location + currentRange.length)
  }
  
  static func renderFirstPage(doc: Document, withTextRange currentRange: CFRange, andFramesetter framesetter: CTFramesetter?) -> CFRange {
    
    let docStyle = UserDefaults.standard.documentStyle
    let frames = docStyle.headerStyle.getContentFrames
    
    var currentRange = currentRange
    // Get the graphics context.
    let currentContext = UIGraphicsGetCurrentContext()
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    currentContext?.textMatrix = .identity
    
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    
//    doc.name.draw(in: frames.title, withAttributes: attributes.title)
//    dateString.draw(in: frames.date, withAttributes: attributes.date)
    
    let frameRect = frames.text
    let framePath = CGMutablePath()
    framePath.addRect(frameRect, transform: .identity)
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    let frameRef = CTFramesetterCreateFrame(framesetter!, currentRange, framePath, nil)
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    currentContext?.translateBy(x: 0, y: _pageRect.height + frameRect.origin.y - 40)
    currentContext?.scaleBy(x: 1.0, y: -1.0)
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext!)
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef)
    currentRange.location += currentRange.length
    currentRange.length = CFIndex(0)
    
    return currentRange
  }
  
  static func renderPage(_ pageNum: Int, withTextRange currentRange: CFRange, andFramesetter framesetter: CTFramesetter?) -> CFRange {
    var currentRange = currentRange
    // Get the graphics context.
    let currentContext = UIGraphicsGetCurrentContext()
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    currentContext?.textMatrix = .identity
    
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    let frameRect = CGRect(x: 40, y: 40, width: _pageRect.width - 80, height: _pageRect.height - 80)
    let framePath = CGMutablePath()
    framePath.addRect(frameRect, transform: .identity)
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    let frameRef = CTFramesetterCreateFrame(framesetter!, currentRange, framePath, nil)
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    currentContext?.translateBy(x: 0, y: _pageRect.height)
    currentContext?.scaleBy(x: 1.0, y: -1.0)
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext!)
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef)
    currentRange.location += currentRange.length
    currentRange.length = CFIndex(0)
    
    return currentRange
  }
}

extension CGRect {
  mutating func change(x: CGFloat, y: CGFloat) {
    change(x: x)
    change(y: y)
  }
  
  mutating func change(y: CGFloat) {
    self = CGRect(x: origin.x, y: y, width: width, height: height)
  }
  
  mutating func change(x: CGFloat) {
    self = CGRect(x: x, y: origin.y, width: width, height: height)
  }
}

private extension HeaderOption {
  typealias Attribute = [NSAttributedString.Key : Any]
  typealias Frames = (title: CGRect, date: CGRect, text: CGRect)
  typealias Attributes = (title: Attribute, date: Attribute, text: Attribute)
  
  private func  _alignmentStyle(_ align: NSTextAlignment) -> NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = align
    return style
  }
  
  var attributes: Attributes {
    
    let primaryFontSize = CGFloat(24)
    let secondaryFontSize = CGFloat(18)
    let textFontSize = CGFloat(16)
    
    let titleAttr: Attribute
    let dateAttr: Attribute
    
    switch self {
    case .verticalTitle, .horizontalTitle:
      titleAttr = [.font: UIFont.boldSystemFont(ofSize: primaryFontSize) ]
      dateAttr = [
        .font: UIFont.boldSystemFont(ofSize: secondaryFontSize),
        .foregroundColor: UIColor.secondaryLabel,
        .paragraphStyle: self == .horizontalTitle ? _alignmentStyle(.right) : _alignmentStyle(.left)
      ]
    case .verticalDate, .horizontalDate:
      dateAttr = [.font: UIFont.boldSystemFont(ofSize: primaryFontSize) ]
      titleAttr = [
        .font: UIFont.boldSystemFont(ofSize: secondaryFontSize),
        .foregroundColor: UIColor.secondaryLabel,
        .paragraphStyle: self == .horizontalTitle ? _alignmentStyle(.right) : _alignmentStyle(.left)
      ]
    }
    
    return (title: titleAttr, date: dateAttr, text: [.font: UIFont.boldSystemFont(ofSize: textFontSize) ])
  }
  
  var getContentFrames: Frames {
    let titleRect: CGRect
    let dateRect: CGRect
    let textRect: CGRect
    let offset: CGFloat = 40
    switch self {
    case .verticalTitle:
      titleRect = CGRect(x: offset,
                         y: offset,
                         width: (_pageRect.width - offset * 2),
                         height: 60)
      dateRect = CGRect(x: offset,
                        y: offset + titleRect.height,
                        width: (_pageRect.width - offset * 2),
                        height: 60)
      textRect = CGRect(x: offset,
                        y: offset * 2 + dateRect.height,
                        width: _pageRect.width - offset * 2,
                        height: _pageRect.height - offset * 5)
    case .horizontalTitle:
      titleRect = CGRect(x: offset,
                         y: offset,
                         width: (_pageRect.width - offset * 2) / 2,
                         height: 60)
      dateRect = CGRect(x: offset + titleRect.width,
                        y: offset,
                        width: (_pageRect.width - offset * 2) / 2,
                        height: 60)
      textRect = CGRect(x: offset,
                        y: offset * 2 + dateRect.height,
                        width: _pageRect.width - offset * 2,
                        height: _pageRect.height - offset * 4)
    case .verticalDate:
      dateRect = CGRect(x: offset,
                        y: offset,
                        width: (_pageRect.width - offset * 2),
                        height: 60)
      titleRect = CGRect(x: offset,
                         y: offset + dateRect.height,
                         width: (_pageRect.width - offset * 2),
                         height: 60)
      textRect = CGRect(x: offset,
                        y: offset * 2 + titleRect.height,
                        width: _pageRect.width - offset * 2,
                        height: _pageRect.height - offset * 5)
    case .horizontalDate:
      dateRect = CGRect(x: offset,
                        y: offset,
                        width: (_pageRect.width - offset * 2) / 2,
                        height: 60)
      titleRect = CGRect(x: offset + dateRect.width,
                         y: offset,
                         width: (_pageRect.width - offset * 2) / 2,
                         height: 60)
      textRect = CGRect(x: offset,
                        y: offset * 2 + dateRect.height,
                        width: _pageRect.width - offset * 2,
                        height: _pageRect.height - offset * 4)
    }
    
    return (title: titleRect, date: dateRect, text: textRect)
  }
}
