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
  lazy var router = LibraryRouter(controller: self)
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  @objc func viewDidBecomeActive() {
      print("viewDidBecomeActive")
    print(UserDefaults.standard.documentsToImport)
    
    guard !UserDefaults.standard.documentsToImport.isEmpty else { return }
    UserDefaults.standard.documentsToImport.forEach{ $0.createFile() }
    UserDefaults.standard.documentsToImport = []
    self.collectionView.reloadData()
  }
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
      let identifier = _listAppearance == .large ? "addNewDocCell" : "addNewDocSmallCell"
      return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath)
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
      self.router.navigate(to: .newDoc)
      return
    }
    let doc = viewModel.source[indexPath.row - 1]
    self.router.navigate(to: .preview(doc))
  }
}

extension LibraryController: UICollectionViewDelegateFlowLayout {
  private var _goldenRatio: CGFloat { 1.61803398875 }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    switch _listAppearance {
    case .large:
      let width = (UIScreen.main.bounds.width) / 2 - 24
      return CGSize(width: width, height: width * 1.3)
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
