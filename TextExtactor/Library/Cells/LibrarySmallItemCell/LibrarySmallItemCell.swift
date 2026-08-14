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
  private var _badge: LibraryDocumentBadge = .none {
    didSet {
      self.isNewBadge.isHidden = _badge == .none
      self.isNewBadge.text = _badge.title
    }
  }
  @IBOutlet weak var menuButton: UIButton! {
    didSet {
      self.menuButton.showsMenuAsPrimaryAction = true
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    _configureAppearance()
  }
  
  var viewModel: LibraryItemCellViewModel! {
    didSet {
      self.trumbnail.image = viewModel.document.image
      self.title.text = viewModel.document.name
      
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm E, d MMM y"
      
      self.subtitle.text = formatter.string(from: viewModel.document.createdAt)
      self._badge = viewModel.badge
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
    blur.tag = 90_003
    blur.translatesAutoresizingMaskIntoConstraints = false
    contentView.insertSubview(blur, at: 0)
    NSLayoutConstraint.activate([
      blur.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      blur.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      blur.topAnchor.constraint(equalTo: contentView.topAnchor),
      blur.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])

    trumbnail.layer.cornerRadius = 12
    trumbnail.layer.cornerCurve = .continuous
    trumbnail.clipsToBounds = true
    menuButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
    menuButton.setPreferredSymbolConfiguration(
      UIImage.SymbolConfiguration(pointSize: 17, weight: .medium),
      forImageIn: .normal
    )
    menuButton.tintColor = .secondaryLabel
    menuButton.backgroundColor = .clear
    menuButton.contentHorizontalAlignment = .center
    menuButton.accessibilityLabel = "More options"
    isNewBadge.backgroundColor = .accentColor
    isNewBadge.textColor = .white
    isNewBadge.layer.cornerRadius = 11
    isNewBadge.clipsToBounds = true
    title.font = .systemFont(ofSize: 17, weight: .semibold)
    subtitle.textColor = .secondaryLabel
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
