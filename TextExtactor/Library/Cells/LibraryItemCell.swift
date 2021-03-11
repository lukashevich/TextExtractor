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
  
  @IBOutlet weak var trumbnail: UIImageView!
  @IBOutlet weak var menuButton: UIButton! {
    didSet {
      self.menuButton.showsMenuAsPrimaryAction = true
      self.menuButton.menu = _menuItems
    }
  }
  @IBOutlet weak var isNewBadge: UILabel!

  var delegate: LibraryItemCellDelegate?
  
  private var _isNew: Bool = false {
    didSet {
      self.isNewBadge.isHidden = !_isNew
    }
  }
  
  var viewModel: LibraryItemCellViewModel! {
    didSet {
      self.trumbnail.image = viewModel.document.image
      self._isNew = viewModel.document.isNew
    }
  }
  
  private var _menuItems: UIMenu {
    let children = [
      UIAction(title: "Share PDF", image: UIImage.doc, handler: _sharePDF),
      UIAction(title: "Share Audio (M4A)", image: UIImage.waveformCircle, handler: _shareAudio),
      UIAction(title: "Delete", image: UIImage.trash, attributes: .destructive, handler: _deleteDoc)
    ]
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
