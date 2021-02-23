//
//  LiraryItemCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import UIKit

protocol LibraryItemCellDelegate {
  func share(file: URL)
}
class LibraryItemCell: UICollectionViewCell, IdentifiableCell {

  static let reuseIdentifier = "libraryCell"
  
  @IBOutlet weak var trumbnail: UIImageView!

  var delegate: LibraryItemCellDelegate?
  
  var viewModel: LibraryItemCellViewModel! {
    didSet {
      self.trumbnail.image = viewModel.document.image
    }
  }
  
  @IBAction func share() {
    delegate?.share(file: viewModel.document.pdfLink)
  }
}
