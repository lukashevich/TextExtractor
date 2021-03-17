//
//  URLPresenter.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.03.2021.
//

import UIKit

enum URLPresenterSource: String {
  case privacy = "https://telegra.ph/Privacy-Policy-03-15-25"
  case tos = "https://telegra.ph/Terms--Conditions-03-15-2"
}

protocol URLPresenter {
  func open(link: URLPresenterSource)
}

extension URLPresenter {
  func open(link: URLPresenterSource) {
    guard let url = URL(string: link.rawValue) else { return }
    UIApplication.shared.open(url)
  }
}
