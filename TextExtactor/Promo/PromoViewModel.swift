//
//  PromoViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 27.05.2022.
//

import Foundation

struct PromoViewModel {
  
  enum ChackResult {
    case success
    case fail
  }
  
  var resultHandler: ((ChackResult) -> ())?
  
  private let _nums: Set<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  private var _code: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ddMMHH"
    return dateFormatter.string(from: Date())
  }

  func checkPromo(_ inputs: [String?]) {
    print(inputs.contains(""))
    
    guard !inputs.contains(""), !inputs.contains(nil), inputs.count == 6 else {
      return
    }
    
    let unwrappedInputs = inputs.compactMap{$0}
    
    let isAllNumners = Set(unwrappedInputs).isSubset(of: _nums)

    guard isAllNumners else {
      resultHandler?(.fail)
      return
    }
    
    switch unwrappedInputs.joined(separator: "") == _code {
    case true:
      resultHandler?(.success)
    case false:
      resultHandler?(.fail)
    }
  }
  
  func markUserAsPromoted() {
    UserDefaults.standard.userPromoted = true
  }
}
