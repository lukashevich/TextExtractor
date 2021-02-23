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
  let locales = Array(SFSpeechRecognizer.supportedLocales())
  
  var filteredLocales = Array(SFSpeechRecognizer.supportedLocales())
  
  var onSelect: ((Locale) -> Void)?
  
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
      cell.locale = filteredLocales[indexPath.row]
    } else {
      cell.locale = locales[indexPath.row]
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isFiltering {
      self.onSelect?(filteredLocales[indexPath.row])
    } else {
      self.onSelect?(locales[indexPath.row])
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
    filteredLocales = locales.filter { (location) -> Bool in
      if let locationStr = location.localizedString(forLanguageCode: location.languageCode!),
         let regionCode = location.regionCode {
        let extendedLocaleStr = regionCode + locationStr
        return extendedLocaleStr.lowercased().contains(searchText.lowercased())
      } else {
        return false
      }
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
