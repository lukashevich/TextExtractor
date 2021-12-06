//
//  PresentationController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.08.2021.
//

import Foundation
import UIKit

final class PresentationController: UIViewController, ShareSheetPresenter, ParalaxBackgrounded {
  var viewModel: PresentationViewModel!
  lazy private var _router = PresentationRouter(controller: self)
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setParalaxBackground()
  }
  
  @IBAction private func _setupPressed() {
    shareFile(at: Bundle.main.url(forResource: viewModel.setupFile.fileName,
                                  withExtension: viewModel.setupFile.fileExtension)!)
  }
  
  @IBAction private func _gotItPressed() {
    let dismissMe = { [unowned self] in dismiss(animated: true, completion: nil) }

    guard !UserDefaults.standard.userSubscribed else {
      dismissMe()
      return
    }
    _router.navigate(to: .paywall(PaywallHandlers(success: dismissMe, deny: dismissMe)))
  }
}
