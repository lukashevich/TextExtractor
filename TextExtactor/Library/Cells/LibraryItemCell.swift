//
//  LiraryItemCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import UIKit

protocol LibraryItemCellDelegate {
  func share(file: URL)
  func docRemoved()
}
class LibraryItemCell: UICollectionViewCell, IdentifiableCell {

  static let reuseIdentifier = "libraryCell"
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var menuButton: UIButton! {
    didSet {
      self.menuButton.showsMenuAsPrimaryAction = true
    }
  }
  @IBOutlet weak var isNewBadge: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var sourceNameLabel: UILabel!
  @IBOutlet weak var docIconView: DocSourceIconView!
  
  var delegate: LibraryItemCellDelegate?
  
  private var _isNew: Bool = false {
    didSet {
      self.isNewBadge.isHidden = !_isNew
    }
  }
  
  var viewModel: LibraryItemCellViewModel! {
    didSet {
      self.textView.text = viewModel.document.text
      self._isNew = viewModel.document.isNew
      
      let formatter = DateFormatter()
      formatter.dateFormat = "d MMM y"
      
      self.dateLabel.text = formatter.string(from: viewModel.document.createdAt)
      self.sourceNameLabel.text = viewModel.document.name
      
      self.docIconView.docType = viewModel.document.source
      
      self.menuButton.menu = _menuItems
    }
  }
  
  private var _menuItems: UIMenu {
    var children = [
      UIAction(title: "SHARE_PDF".localized, image: UIImage.doc, handler: _sharePDF),
      UIAction(title: "SHARE_M4A".localized, image: UIImage.waveformCircle, handler: _shareAudio),
      UIAction(title: "DELETE".localized, image: UIImage.trash, attributes: .destructive, handler: _deleteDoc)
    ]
    
    if self.viewModel.document.source == .picture {
      children.remove(at: 1)
    }
  
    return UIMenu(title: "", options: .displayInline, children: children)
  }
  
  var _sharePDF: UIActionHandler {
    return { _ in self.delegate?.share(file: self.viewModel.document.pdfLink) }
  }
  
  var _shareAudio: UIActionHandler {
    return { _ in self.delegate?.share(file: self.viewModel.document.audioLink) }
  }
  
  var _deleteDoc: UIActionHandler {
    return { _ in
      FileManager.removeDocument(self.viewModel.document)
      self.delegate?.docRemoved()
    }
  }
}


extension UIImage {
  var inverted: UIImage {
    guard let cgImage = self.cgImage, UITraitCollection.current.userInterfaceStyle == .dark else { return self }
    let ciImage = CoreImage.CIImage(cgImage: cgImage)
    guard let filter = CIFilter(name: "CIColorInvert") else { return self }
    filter.setDefaults()
    filter.setValue(ciImage, forKey: kCIInputImageKey)
    let context = CIContext(options: nil)
    guard let outputImage = filter.outputImage else { return self }
    guard let outputImageCopy = context.createCGImage(outputImage, from: outputImage.extent) else { return self }
    return UIImage(cgImage: outputImageCopy, scale: self.scale, orientation: .up)
  }
}
