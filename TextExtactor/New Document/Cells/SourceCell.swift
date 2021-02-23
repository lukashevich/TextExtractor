//
//  SourceCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit

protocol SourceCellDelegate {
  func pickFile()
}

class SourceCell: UITableViewCell, ExpandableCell {
  @IBOutlet public weak var hiddenView: UIView! {
    didSet {
      hiddenView.isHidden = true
    }
  }
  
  var delegate: SourceCellDelegate?
  var url: URL? {
    didSet {
      
    }
  }
  
  @IBAction func pickFile() {
    delegate?.pickFile()
  }
}


