//
//  LocaleChangingController.swift
//  VoiceRecorder
//
//  Created by Lucas on 20.05.2020.
//  Copyright © 2020 Lucas. All rights reserved.
//

import UIKit
import Speech

protocol LocaleDelegate {
  func localeChanged(locale:Locale)
}

final class LocalesController: UIViewController {
  
  @IBOutlet weak var localesTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  let searchController = UISearchController(searchResultsController: nil)
  let locales = Recognizer.groupedLocales.compactMap(\.key).sorted(by: { $0 < $1 })
  var viewModel: LocalesViewModel!
  var filteredLocales = Recognizer.groupedLocales.compactMap(\.key).sorted(by: { $0 < $1 })
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSearchBar()
  }
}


extension LocalesController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredLocales.count
    }
    return locales.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: LocaleCell.reuseIdentifier, for: indexPath as IndexPath) as! LocaleCell
    if isFiltering {
      cell.localeCode = filteredLocales[indexPath.row]
    } else {
      cell.localeCode = locales[indexPath.row]
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let code: String?
    if isFiltering {
      code = filteredLocales[indexPath.row]
    } else {
      code = locales[indexPath.row]
    }
    
    if let localeCode = code {
      let locale = Locale(identifier: localeCode)
      self.viewModel.onSelect?(locale)
    }

    self.dismiss(animated: true, completion: nil)
  }
}

extension LocalesController: UISearchResultsUpdating {
  
  var isSearchBarEmpty: Bool {
    return filteredLocales.isEmpty
  }
  
  var isFiltering: Bool {
    let searchText = searchBar.text ?? ""
    return !searchText.isEmpty && !isSearchBarEmpty
  }
  
  func setupSearchBar() {
    searchBar.placeholder = "All Locales"
    searchBar.delegate = self
    //      searchBar.scopeButtonTitles = Recognizer..allCases.map { $0.rawValue }
    
    definesPresentationContext = true
    navigationItem.hidesSearchBarWhenScrolling = false
  }
  
  func filterContentForSearchText(_ searchText: String) {
    filteredLocales = locales.filter { (code) -> Bool in
      let locale = Locale(identifier: code)
      let localeStr = locale.localizedString(forLanguageCode: code) ?? ""
      let extendedLocaleStr = code + localeStr
      return extendedLocaleStr.lowercased().contains(searchText.lowercased())
    }
    
    localesTableView.reloadSections([0], with: .automatic)
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
    
  }
}

extension LocalesController: UISearchBarDelegate {
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    filterContentForSearchText(searchBar.text!)
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    filterContentForSearchText(searchBar.text!)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}
