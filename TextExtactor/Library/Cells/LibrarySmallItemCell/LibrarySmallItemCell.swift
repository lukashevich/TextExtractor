//
//  LibrarySmallItemCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 17.02.2021.
//

import UIKit

class LibrarySmallItemCell: UICollectionViewCell, IdentifiableCell {
  static let reuseIdentifier = "librarySmallCell"
  
  @IBOutlet weak var trumbnail: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var subtitle: UILabel!
  @IBOutlet weak var isNewBadge: UILabel!

  var delegate: LibraryItemCellDelegate?
  private var _isNew: Bool = false {
    didSet {
      self.isNewBadge.isHidden = !_isNew
    }
  }
  @IBOutlet weak var menuButton: UIButton! {
    didSet {
      self.menuButton.showsMenuAsPrimaryAction = true
      self.menuButton.menu = _menuItems
    }
  }
  
  var viewModel: LibraryItemCellViewModel! {
    didSet {
      self.trumbnail.image = viewModel.document.image
      self.title.text = viewModel.document.name
      
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm E, d MMM y"
      
      self.subtitle.text = formatter.string(from: viewModel.document.createdAt)
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
