//
//  LibraryController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 14.02.2021.
//

import Foundation
import UIKit

final class LibraryController: UICollectionViewController, ShareControllerPresenter, TabBared, HolidayAffected {

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

    collectionView.backgroundColor = .clear
    collectionView.tintColor = .accentColor
    _configureAppearance()
    
    NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
  }
  
  @objc func viewDidBecomeActive() {
    guard !UserDefaults.standard.documentsToImport.isEmpty else { return }
    UserDefaults.standard.documentsToImport.forEach{ $0.createFile() }
    UserDefaults.standard.documentsToImport = []
    self.collectionView.reloadData()
  }

  private func _configureAppearance() {
    let backdrop = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    backdrop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collectionView.backgroundView = backdrop
  }

  private func _styleAddCell(_ cell: UICollectionViewCell) {
    let surface = cell.contentView
    surface.backgroundColor = .clear
    surface.layer.cornerRadius = 20
    surface.layer.cornerCurve = .continuous
    surface.layer.borderWidth = 1
    surface.layer.borderColor = UIColor.accentColor.withAlphaComponent(0.32).cgColor
    surface.clipsToBounds = true

    if surface.viewWithTag(90_001) == nil {
      let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
      blur.tag = 90_001
      blur.translatesAutoresizingMaskIntoConstraints = false
      surface.insertSubview(blur, at: 0)
      NSLayoutConstraint.activate([
        blur.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
        blur.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
        blur.topAnchor.constraint(equalTo: surface.topAnchor),
        blur.bottomAnchor.constraint(equalTo: surface.bottomAnchor)
      ])
    }

    _styleAddCellSubviews(in: surface)
  }

  private func _styleAddCellSubviews(in view: UIView) {
    view.subviews.forEach { subview in
      if subview.tag != 90_001 {
        if let imageView = subview as? UIImageView {
          imageView.tintColor = .accentColor
        } else if let label = subview as? UILabel {
          label.textColor = .accentColor
          label.font = .systemFont(ofSize: 17, weight: .semibold)
        } else {
          subview.backgroundColor = .clear
        }
        _styleAddCellSubviews(in: subview)
      }
    }
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
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath as IndexPath)
      _styleAddCell(cell)
      return cell
    }
    
    switch _listAppearance {
    case .large:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryItemCell.reuseIdentifier, for: indexPath as IndexPath) as! LibraryItemCell
      let document = viewModel.source[indexPath.row - 1]
      cell.viewModel = LibraryItemCellViewModel(document: document, badge: viewModel.badge(for: document))
      cell.delegate = self
      
      return cell
    case .small:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibrarySmallItemCell.reuseIdentifier, for: indexPath as IndexPath) as! LibrarySmallItemCell
      let document = viewModel.source[indexPath.row - 1]
      cell.viewModel = LibraryItemCellViewModel(document: document, badge: viewModel.badge(for: document))
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
