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
  
  var localeCode: String? {
    didSet {
      guard let code = localeCode else { return }
      let loc = Locale(identifier: code)
      title.text = loc.country
      subtitle.text = loc.debugDescription
      self._isPicked = UserDefaults.standard.extractingLocale.languageCode == code
    }
  }
  
  private var _isPicked: Bool = false {
    didSet {
      switch _isPicked {
      case true:
        self.accessoryType = .checkmark
        self.backgroundColor = .secondaryAccentColor
      case false:
        self.accessoryType = .none
        self.backgroundColor = .systemBackground
      }
    }
  }
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var subtitle: UILabel!  
}
