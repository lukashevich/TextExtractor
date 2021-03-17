//
//  PaywallSmallView.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.03.2021.
//

import UIKit

final class PaywallCell: UITableViewCell {
  
  @IBOutlet private weak var _playButton: UIButton!

  override class func awakeFromNib() {
    SubscriptionHelper.retrieveInfo {
      print("FUC")
    }
  }
 
  @IBAction func subscribe() {
    SubscriptionHelper.retrieveInfo {
      print("FUC")
    }
  }
}
