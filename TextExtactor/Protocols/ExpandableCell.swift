//
//  ExpandableCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit

protocol ExpandableCell where Self: UITableViewCell {
  var hiddenView: UIView! { get }
}
