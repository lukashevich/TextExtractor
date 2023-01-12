//
//  MessageTranscriberAnalytics.swift
//  Sharing
//
//  Created by Oleksandr Lukashevych on 1/12/23.
//

import Foundation

enum MessageTranscriberEvent: AnalyticEvent {
  var _prefix: String { "message_transcriber_"}
    
  case shown
  case getAttachments(Int)
  case proccess(Int)
  case recognizeResult(Bool)
  
  var key: String {
    switch self {
    case .shown: return "shown"
    case .getAttachments:
      return "get_attachements"
    case .proccess:
      return "process"
    case .recognizeResult:
      return "recognize_result"
    }
  }

  
  var parameters: Params {
    switch self {
    case .shown: return nil
    case .getAttachments(let count), .proccess(let count):
      return ["count": count]
    case .recognizeResult(let isSuccessful):
      return ["isSuccessful": isSuccessful]
    }
  }
}
