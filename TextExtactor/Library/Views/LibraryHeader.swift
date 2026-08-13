//
//  LibraryHeader.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

protocol LibraryHeaderDelegate {
  func sorted(via sort: LibraryHeader.Sort)
}

final class LibraryHeader: UICollectionReusableView {
  
  var delegate: LibraryHeaderDelegate?
  
  enum Sort: String, CaseIterable {
    case recent = "RECENT"
    case title = "TITLE"
    case modified = "MODIFIED"
    
    var localized: String {
      rawValue.localized
    }
  }
  
  @IBOutlet weak var sortButton: UIButton! {
    didSet {
      self.sortButton.showsMenuAsPrimaryAction = true
      self.sortButton.menu = _sortMenuItems
      self.sortButton.setTitle(Sort.recent.localized, for: .normal)
      self.sortButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
      self.sortButton.tintColor = .accentColor
      self.sortButton.setTitleColor(.accentColor, for: .normal)
      self.sortButton.backgroundColor = UIColor.accentColor.withAlphaComponent(0.14)
      self.sortButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
      self.sortButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
      self.sortButton.layer.cornerRadius = 16
      self.sortButton.layer.cornerCurve = .continuous
      self.sortButton.accessibilityLabel = "SORT".localized
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    backgroundColor = .clear
  }
  
  private var _sortMenuItems: UIMenu {
    return UIMenu(title: "", options: .displayInline, children: Sort.allCases.map { sort in
      return UIAction(title: sort.localized, handler: { _ in
        self.sortButton.setTitle(sort.localized, for: .normal)
        self.sortButton.accessibilityValue = sort.localized
        self.delegate?.sorted(via: sort)
      })
    })
  }
}
