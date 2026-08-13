//
//  SettingsController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

final class SettingsController: UIViewController, URLPresenter, AlertPresenter {
  
  @IBOutlet private weak var _fullPreloader: UIView!
  @IBOutlet private weak var _fullPreloaderActivity: UIActivityIndicatorView!
  @IBOutlet private weak var _settingsTable: UITableView!

  private lazy var _router = SettingsRouter(controller: self)
  
  var viewModel = SettingsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _configureAppearance()
    self.viewModel.updateContent = {
      self._settingsTable.reloadData()
    }
  }

  private func _configureAppearance() {
    view.backgroundColor = .clear

    let backdrop = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    backdrop.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(backdrop, at: 0)
    NSLayoutConstraint.activate([
      backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      backdrop.topAnchor.constraint(equalTo: view.topAnchor),
      backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    _settingsTable.backgroundColor = .clear
    _settingsTable.tintColor = .accentColor
    _settingsTable.separatorColor = UIColor.accentColor.withAlphaComponent(0.16)
    _settingsTable.sectionHeaderTopPadding = 14
    _settingsTable.sectionHeaderHeight = 34
    _settingsTable.sectionFooterHeight = 14

    _fullPreloader.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.72)
    _fullPreloaderActivity.color = .accentColor
  }
}

extension SettingsController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.source[section].count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.viewModel.source.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return UserDefaults.standard.userSubscribed ? "SUBSCRIPTION".localized : nil
    case 1: return "EXPORT".localized
    case 2: return "SUPPORT".localized
    case 3: return "ADDITIONAL".localized
    default: return nil
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: self.viewModel.source[indexPath.section][indexPath.row].rawValue, for: indexPath)
    _style(cell)
    
    if self.viewModel.source[indexPath.section][indexPath.row] == .subscription {
      (cell as? PaywallCell)?.subscriptionHandler = self.viewModel.subscribed
      (cell as? PaywallCell)?.problemHandler = self._someProblem
    }
    
    return cell
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let header = view as? UITableViewHeaderFooterView else { return }
    header.textLabel?.textColor = .accentColor
    header.textLabel?.font = .systemFont(ofSize: 13, weight: .bold)
  }

  private func _style(_ cell: UITableViewCell) {
    cell.tintColor = .accentColor
    cell.backgroundColor = .secondarySystemGroupedBackground
    cell.contentView.backgroundColor = .clear

    let selectedBackground = UIView()
    selectedBackground.backgroundColor = UIColor.accentColor.withAlphaComponent(0.12)
    cell.selectedBackgroundView = selectedBackground
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch self.viewModel.source[indexPath.section][indexPath.row] {
    case .subscription, .audio: break
    case .document: self._router.navigate(to: .toExportedDoc)
    case .restore: self._restorePurchases()
    case .howToUse: self._router.navigate(to: .toPresentation)
    case .privacy: self.open(link: .privacy)
    case .tos: self.open(link: .tos)
    }
  }
  
  private func _someProblem(_ error: Error){
    self.showAlert(.error(error))
  }
  
  private func _showPreloader() {
    self._fullPreloaderActivity.startAnimating()
    self._fullPreloader.showAnimated()
  }
  
  private func _hidePreloader() {
    self._fullPreloader.hideAnimated()
  }
  
  private func _restorePurchases() {
    self._showPreloader()
    SubscriptionHelper.restore { result in
      switch result {
      case .success(let receipt):
        let purchaseResult = SubscriptionHelper.verifySubscriptions(receipt)
        DispatchQueue.main.async {
          self._hidePreloader()
          switch purchaseResult {
          case .purchased:
            self.viewModel.subscribed()
          case .expired:
            UserDefaults.standard.userSubscribed = false
          case .notPurchased:
            UserDefaults.standard.userSubscribed = false
          }
        }
      case .error(let error):
        self._someProblem(error)
        self._hidePreloader()
      }
    }
  }
}
