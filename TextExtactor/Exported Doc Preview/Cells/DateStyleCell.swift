//
//  DateStyleCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 07.04.2021.
//

import UIKit

final class DateStyleCell: UITableViewCell {
  
  @IBOutlet private weak var _dateStyleLabel: UILabel!
  
  var dateStyle: DateFormatter.Style = .medium {
    didSet {
      let formatter = DateFormatter()
      formatter.dateStyle = dateStyle
      _dateStyleLabel.text = formatter.string(from: Date())
    }
  }
}
