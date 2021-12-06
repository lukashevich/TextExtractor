//
//  ShareSheetPresenter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.08.2021.
//

import Foundation
import UIKit

protocol ShareSheetPresenter { }

extension ShareSheetPresenter where Self: UIViewController {
  func shareFile(at url: URL) {
    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    present(activityViewController, animated: true, completion: nil)
  }
}
