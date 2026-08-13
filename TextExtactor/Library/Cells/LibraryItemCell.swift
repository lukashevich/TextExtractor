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

  override func awakeFromNib() {
    super.awakeFromNib()
    _configureAppearance()
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

  private func _configureAppearance() {
    contentView.backgroundColor = .clear
    contentView.layer.cornerRadius = 20
    contentView.layer.cornerCurve = .continuous
    contentView.layer.borderWidth = 1
    contentView.layer.borderColor = UIColor.accentColor.withAlphaComponent(0.18).cgColor
    contentView.clipsToBounds = true

    let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    blur.tag = 90_002
    blur.translatesAutoresizingMaskIntoConstraints = false
    contentView.insertSubview(blur, at: 0)
    NSLayoutConstraint.activate([
      blur.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      blur.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      blur.topAnchor.constraint(equalTo: contentView.topAnchor),
      blur.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])

    textView.backgroundColor = .clear
    textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
    textView.font = .systemFont(ofSize: 15, weight: .regular)
    contentView.subviews.compactMap { $0 as? TransparentGradientView }.forEach { $0.isHidden = true }
    menuButton.tintColor = .accentColor
    menuButton.backgroundColor = UIColor.accentColor.withAlphaComponent(0.14)
    menuButton.layer.cornerRadius = 14
    menuButton.layer.cornerCurve = .continuous
    menuButton.clipsToBounds = true
    isNewBadge.backgroundColor = .accentColor
    isNewBadge.textColor = .white
    isNewBadge.layer.cornerRadius = 11
    isNewBadge.clipsToBounds = true
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
    return { _ in
      PDFCreator.createPDF(for: self.viewModel.document)
      self.delegate?.share(file: self.viewModel.document.pdfLink)
    }
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
