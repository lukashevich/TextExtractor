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
  
  var delegate: LibraryItemCellDelegate?
  
  var viewModel: LibraryItemCellViewModel! {
    didSet {
      self.trumbnail.image = viewModel.document.image
      self.title.text = viewModel.document.name
      
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm E, d MMM y"
      
      self.subtitle.text = formatter.string(from: viewModel.document.createdAt)
    }
  }
  
  @IBAction func share() {
    delegate?.share(file: viewModel.document.pdfLink)
  }
}
