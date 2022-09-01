//
//  Recognizer.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import Speech

final class Recognizer {
  
  static var locales: [Locale] { Array(SFSpeechRecognizer.supportedLocales()) }
  static var groupedLocales:[String?: [Locale]]  {
    locales.group(by: \.languageCode)
  }
  private static var _stopped: Bool = false
  
  static var fullText = [Int: String]()
  
  static func checkStatus(completion: @escaping (Bool) -> Void) {
    SFSpeechRecognizer.requestAuthorization { authStatus in
      if authStatus == .authorized {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  static func validateRecord(at url:URL, in locale:Locale, completion: ((Bool) -> ())? = nil) {
    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
      completion?(false)
      return
    }
    
    if !recognizer.isAvailable {
      completion?(false)
      return
    }
    
    let request = SFSpeechURLRecognitionRequest(url: url)
    request.requiresOnDeviceRecognition = true
    recognizer.recognitionTask(with: request) { (result, error) in
      guard let result = result else {
        completion?(false)
        return
      }
      completion?(true)
    }
  }
  
  private static var _notFinalTranscription: String?
  static func recognizeMedia(at url:URL, in locale:Locale, completion: ((String?, TranscribeError?) -> ())? = nil)  {
    
    _notFinalTranscription = nil
    
    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
      completion?(nil, .noPermission)
      return
    }
    
    guard recognizer.isAvailable else {
      completion?(nil, .notAvailable)
      return
    }
    
    
    let request = SFSpeechURLRecognitionRequest(url: url)
    request.requiresOnDeviceRecognition = true
    
    recognizer.recognitionTask(with: request) { (result, error) in
      guard let result = result else {
        switch _notFinalTranscription {
        case .none:
          completion?(nil, .failed)
        case .some(let notFinalText):
          completion?(notFinalText, nil)
        }
        return
      }
      
      switch result.isFinal {
      case true:
        completion?(result.bestTranscription.formattedString, nil)
      case false:
        _notFinalTranscription = result.bestTranscription.formattedString
      }
    }
  }
  
  static func recognizeMediaConcurrently(at urls:[URL], in locale:Locale, newText: @escaping ((String, Int) -> ()), completion: ((String) -> ())? = nil) {
    
    var result = [Int:String]()
    let group = DispatchGroup()
    
    let concurrentQueue = DispatchQueue.init(label: "concurrent", attributes: .concurrent)
    //    let concurrentQueue = DispatchQueue.global(qos: .utility)
    
    let startDate = Date()
    urls.enumerated().forEach { index, url in
      DispatchQueue.global(qos: .utility).async(group: group) {
        
        Recognizer.recognizeMedia(at: url, in: locale) { text, error in
          
          switch error {
          case .none:
            newText(text ?? "" , index)
            result[index] = text
          case .some(let transcribeError):
            result[index] = "{...}"
          }
        }
      }
      Thread.sleep(forTimeInterval: 1)

    }
    
    group.notify(queue: .main) {
      print("FULL TIME", Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
    }
  }
  
  static func recognizeMedia(at urls:[URL], in locale:Locale, newText: @escaping ((String) -> ()), completion: ((String) -> ())? = nil) {
    var newUrls = urls
    guard let url = newUrls.first else {
      return
    }
    
    guard !_stopped else {
      self._stopped = false
      return
    }
    
    Recognizer.recognizeMedia(at: url, in: locale) { (text, error) in
      guard !_stopped else { return }
      
      newUrls.removeFirst()

      guard let error = error else {
        switch text {
        case .some(let transcribed) where !transcribed.isEmpty:
          newText(transcribed + ", ")
          self.recognizeMedia(at: newUrls, in: locale, newText: newText)
        default: break
        }
        return
      }
    }
  }
  
  static func enableRecognizing() {
    self._stopped = false
  }
  
  static func stopRecognizing() {
    self._stopped = true
  }
}
