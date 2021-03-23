//
//  LibraryController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

final class LibraryController: UICollectionViewController, ShareControllerPresenter , TabBared {

  enum ListAppearance {
    case large
    case small
    
    mutating func toggle() {
      switch self {
      case .large: self = .small
      case .small: self = .large
      }
    }
  }

  let viewModel = LibraryViewModel()
  private lazy var _router = LibraryRouter(controller: self)
  private var _listAppearance = ListAppearance.large {
    didSet {
      collectionView.reloadData()
    }
  }

  @IBAction func toggleListAppearance(sender: UIButton) {
    sender.isSelected.toggle()
    _listAppearance.toggle()
  }
  
  func appeared() {
    self.collectionView.reloadData()
  }
  
//  override func viewDidLoad() {
//    self._router.navigate(to: .paywall(PaywallHandlers(success: nil, deny: nil)))
//  }
}

extension LibraryController {
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath as IndexPath) as! LibraryHeader
    headerView.delegate = self
    return headerView
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.source.count + 1
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard indexPath.row > 0 else {
      return collectionView.dequeueReusableCell(withReuseIdentifier: "addNewDocCell", for: indexPath as IndexPath)
    }
    
    switch _listAppearance {
    case .large:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryItemCell.reuseIdentifier, for: indexPath as IndexPath) as! LibraryItemCell
      cell.viewModel = LibraryItemCellViewModel(document: viewModel.source[indexPath.row - 1])
      cell.delegate = self
      
      return cell
    case .small:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibrarySmallItemCell.reuseIdentifier, for: indexPath as IndexPath) as! LibrarySmallItemCell
      cell.viewModel = LibraryItemCellViewModel(document: viewModel.source[indexPath.row - 1])
      cell.delegate = self

      return cell
    }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    self.collectionView.reloadData()
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.row > 0 else {
      self._router.navigate(to: .newDoc)
      return
    }
    let doc = viewModel.source[indexPath.row - 1]
    self._router.navigate(to: .preview(doc))
  }
}

extension LibraryController: UICollectionViewDelegateFlowLayout {
  private var _goldenRatio: CGFloat { 1.61803398875 }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch _listAppearance {
    case .large:
      let width = (UIScreen.main.bounds.width) / 3 - 26
      return CGSize(width: width, height: width * _goldenRatio)
    case .small:
      return CGSize(width: UIScreen.main.bounds.width - 32, height: 88)
    }
  }
}

extension LibraryController: LibraryItemCellDelegate {
  func share(file: URL) {
    self.share(object: file)
  }
  
  func docRemoved() {
    self.collectionView.reloadData()
  }
}

extension LibraryController: LibraryHeaderDelegate {
  func sorted(via sort: LibraryHeader.Sort) {
    self.viewModel.sortDocuments(sort)
    self.collectionView.reloadData()
  }
}
