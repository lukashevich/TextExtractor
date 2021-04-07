//
//  DateStylePicker.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 07.04.2021.
//

import UIKit

final class DateStylePicker: UIViewController {
  
  typealias DismissHandler = (() -> ())

  var viewModel: DateStylePickerViewModel!
  
  enum Identifier: String {
    case full = "full"
    case long = "long"
    case medium = "medium"
    case short = "short"
    
    var title: String {
      let formatter = DateFormatter()
      formatter.dateStyle = style
      return formatter.string(from: Date())
    }
    
    var style: DateFormatter.Style {
      switch self {
        case .full: return .full
        case .long: return .long
        case .medium: return .medium
        case .short: return .short
      }
    }
  }
  
  private var _source: [[Identifier]] {
    return [[.full, .long, .medium, .short]]
  }
  
  private var _currentDataStyle: DateFormatter.Style {
    UserDefaults.standard.documentStyle.dateStyle
  }
}

extension DateStylePicker: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return _source[section].count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return _source.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier =  _source[indexPath.section][indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
        
    cell.textLabel?.text = identifier.title
    cell.accessoryType = identifier.style == _currentDataStyle ? . checkmark : .none
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let identifier =  _source[indexPath.section][indexPath.row]
    UserDefaults.standard.documentStyle = UserDefaults.standard.documentStyle.copy(date: identifier.style)
    self.viewModel.dismissHandler?()
    self.dismiss(animated: true, completion: nil)
  }
}
