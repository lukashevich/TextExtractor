//
//  Date+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 18.11.2021.
//

import Foundation

private var _dateFormatter: DateFormatter {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "dd.MM.yyyy"
  return dateFormatter
}

extension Date {
  static var christmassRange: ClosedRange<Date> {
    let christmasStart = _dateFormatter.date(from: "01.12.2021")!
    let christmasEnd = _dateFormatter.date(from: "07.01.2022")!
    return christmasStart...christmasEnd
  }
  
  static var helloweenRange: ClosedRange<Date> {
    let helloweenStart = _dateFormatter.date(from: "28.10.2021")!
    let helloweenEnd = _dateFormatter.date(from: "01.11.2021")!
    return helloweenStart...helloweenEnd
  }
}
