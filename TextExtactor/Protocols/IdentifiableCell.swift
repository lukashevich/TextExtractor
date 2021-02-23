//
//  IdentifiableCell.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 16.02.2021.
//

import UIKit

protocol IdentifiableCell where Self: UICollectionViewCell {
  static var reuseIdentifier: String { get }
}
