//
//  SettingsController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

final class SettingsController: UIViewController, URLPresenter {
  
  private lazy var _router = SettingsRouter(controller: self)
  
  enum Identifier: String {
    case subscription = "subscription"
    case restore = "restore"
    case privacy = "privacy"
    case tos = "tos"
  }
  
  private let _source: [[Identifier]] = [
    [.subscription],
    [.privacy,
     .tos]
  ]
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return _source[section].count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return _source.count
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let vw = UIView()
    return vw
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: _source[indexPath.section][indexPath.row].rawValue, for: indexPath)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch _source[indexPath.section][indexPath.row] {
    case .subscription: break
    case .restore:  break
    case .privacy: self.open(link: .privacy)
    case .tos: self.open(link: .tos)
    }
  }
}
