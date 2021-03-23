//
//  PeriodUnit+Extension.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 23.03.2021.
//

import StoreKit

extension SKProduct.PeriodUnit {
  var stringValue: String {
    switch self {
    case .day: return "DAY".localized
    case .week: return "WEEK".localized
    case .month: return "MONTH".localized
    case .year: return "YEAR".localized
    @unknown default: return ""
    }
  }
}
