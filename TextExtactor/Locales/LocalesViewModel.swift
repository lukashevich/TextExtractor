//
//  LocalesViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 13.03.2021.
//

import Foundation

typealias LocalePickerHandler = ((Locale) -> Void)

struct LocalesViewModel {
  var onSelect: LocalePickerHandler?
}
