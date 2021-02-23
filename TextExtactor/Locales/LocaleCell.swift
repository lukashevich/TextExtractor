//
//  LocaleCell.swift
//  VoiceRecorder
//
//  Created by Lucas on 20.05.2020.
//  Copyright © 2020 Lucas. All rights reserved.
//

import UIKit

class LocaleCell: UITableViewCell {
  
  static let reuseIdentifier = "localeCell"
  
  var locale:Locale? {
    didSet {
      guard let loc = locale else { return }
      
      title.text = loc.country
      subtitle.text = loc.debugDescription
    }
  }
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var subtitle: UILabel!  
}
