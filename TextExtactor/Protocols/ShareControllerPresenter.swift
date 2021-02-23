//
//  ShareControllerPresenter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import UIKit

protocol ShareControllerPresenter where Self: UIViewController {}

extension ShareControllerPresenter {
  func share(object: Any, completion: ((Bool) -> Void)? = nil) {
    let controller = UIActivityViewController(activityItems: [object], applicationActivities: nil)
    controller.completionWithItemsHandler = { (_, completed: Bool, _, _) in
      completion?(completed)
    }
    
    present(controller, animated: true)
  }
}
