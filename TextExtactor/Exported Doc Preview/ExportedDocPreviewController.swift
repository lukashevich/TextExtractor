//
//  ExportedDocPreviewController.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 06.04.2021.
//

import UIKit

final class ExportedDocPreviewController: UIViewController {
  
  @IBOutlet private weak var _previewLeftTopLabel: UILabel!
  @IBOutlet private weak var _previewLeftBottomLabel: UILabel!
  
  @IBOutlet private weak var _previewRightTopLabel: UILabel!
  @IBOutlet private weak var _previewRightBottomLabel: UILabel!
  
  @IBOutlet private var _dateLabels: [UILabel]!

  var formattedDateString: String {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.dateStyle = UserDefaults.standard.documentStyle.dateStyle
    return formatter.string(from: Date())
  }
  
  @IBOutlet var headerStyleStacks: [UIStackView]!
  private lazy var _previewLabels = [
    _previewLeftTopLabel,
    _previewLeftBottomLabel,
    _previewRightTopLabel,
    _previewRightBottomLabel
  ]
  
  var viewModel: ExportedDocPreviewViewModel!
  private lazy var _router = ExportedDocPreviewRouter(controller: self)
  
  enum Identifier: String {
    case title = "title"
    case date = "date"
  }
  
  private var _source: [[Identifier]] {
    return [[.date]]
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self._dateLabels.forEach { $0.text = self.formattedDateString }
    
    self.viewModel.headerStyleUpdated = { headerStyle in
      
      self._previewLabels.forEach { $0?.text = nil }
      
      let newDocumentString = "TITLE".localized

      switch headerStyle {
      case .verticalTitle:
        self._previewLeftTopLabel.text = newDocumentString
        self._previewLeftBottomLabel.text = self.formattedDateString
      case .horizontalTitle:
        self._previewLeftTopLabel.text = newDocumentString
        self._previewRightTopLabel.text = self.formattedDateString
      case .verticalDate:
        self._previewLeftTopLabel.text = self.formattedDateString
        self._previewLeftBottomLabel.text = newDocumentString
      case .horizontalDate:
        self._previewLeftTopLabel.text = self.formattedDateString
        self._previewRightTopLabel.text = newDocumentString
      }
    }
    
    let docStyle = UserDefaults.standard.documentStyle
    self._selectHeaderStyle(with: docStyle.headerStyle)
  }
}

extension ExportedDocPreviewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return _source[section].count
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return _source.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "ITEMS".localized
      default: return nil
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = _source[indexPath.section][indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
    
    if identifier == .date {
      (cell as? DateStyleCell)?.dateStyle = UserDefaults.standard.documentStyle.dateStyle
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch _source[indexPath.section][indexPath.row] {
    case .title: break
    case .date:
      let dateChanged = {
        self._dateLabels.forEach{ $0.text = self.formattedDateString }
  
        let headerStyle = self.viewModel.headerStyle
        self.viewModel.headerStyle = headerStyle
        
        tableView.reloadData()
      }
      _router.navigate(to: .toDateStylePicker(dateChanged))
    }
  }
  
  private func _selectHeaderStyle(with style: HeaderOption) {
    guard let view = headerStyleStacks.filter({ $0.tag == style.rawValue }).first else {
      return
    }
    headerStyleStacks.forEach { $0.backgroundColor = .systemBackground }
    view.backgroundColor = .secondaryAccentColor
    self.viewModel.headerStyle = style
  }
  
  @IBAction func close() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func headerOptionPicked(_ sender: UITapGestureRecognizer) {
    guard let view = sender.view, let option = HeaderOption(rawValue: view.tag) else {
      return
    }
    
    UserDefaults.standard.documentStyle = UserDefaults.standard.documentStyle.copy(header: option)

    self._selectHeaderStyle(with: option)
  }
}