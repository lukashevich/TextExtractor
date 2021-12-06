//
//  SettingsController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import UIKit

final class SettingsController: UIViewController, URLPresenter, AlertPresenter, HolidayAffected {
  
  @IBOutlet private weak var _fullPreloader: UIView!
  @IBOutlet private weak var _fullPreloaderActivity: UIActivityIndicatorView!
  @IBOutlet private weak var _settingsTable: UITableView!

  private lazy var _router = SettingsRouter(controller: self)
  
  var viewModel = SettingsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupHolidayBackgound()
    self.viewModel.updateContent = {
      self._settingsTable.reloadData()
    }
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
    
    if self.viewModel.source[indexPath.section][indexPath.row] == .subscription {
      (cell as? PaywallCell)?.subscriptionHandler = self.viewModel.subscribed
      (cell as? PaywallCell)?.problemHandler = self._someProblem
    }
    
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch self.viewModel.source[indexPath.section][indexPath.row] {
    case .subscription, .audio: break
    case .document: self._router.navigate(to: .toExportedDoc)
    case .restore: self._restorePurchases()
    case .howToUse: self._router.navigate(to: .toPresentation)
    case .feedback: self._router.navigate(to: .toFeedback)
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
