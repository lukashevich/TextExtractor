//
//  Recognizer.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import Speech

final class Recognizer {
  
  static var locales: [Locale] {
    return Array(SFSpeechRecognizer.supportedLocales())
  }
  
  static var fullText = [Int: String]() {
    didSet {
      print("fullText", fullText.sorted(by: { $0.key < $1.key }).reduce("", { $0 + $1.value }))
    }
  }
  
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
  
  static func recognizeRecord(at url:URL, in locale:Locale, completion: ((String) -> ())? = nil)  {
    
    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
      print("Speech recognition not available for specified locale")
      return
    }
    
    if !recognizer.isAvailable {
      print("Speech recognition not currently available")
      return
    }
    
//    recognizer.supportsOnDeviceRecognition = true
    print(recognizer.supportsOnDeviceRecognition)
    let request = SFSpeechURLRecognitionRequest(url: url)
    //        if #available(iOS 13, *) {
    request.requiresOnDeviceRecognition = true
//    request.shouldReportPartialResults = true
    
    //        }
    
    recognizer.recognitionTask(with: request) { (result, error) in
      guard let result = result else {
        completion?("")

        print("SFSpeechRecognizer error", error, recognizer.isAvailable)
        // Recognition failed, so check error for details and handle it
        return
      }
      // Print the speech that has been recognized so far
      if result.isFinal {
        print("Speech in the file is \(result.bestTranscription.formattedString)")
        completion?(result.bestTranscription.formattedString)
      }
    }
  }
  static var testRes = "" {
    didSet {
      print("=====", testRes)
    }
  }
  
  static func test(at urls:[URL], in locale:Locale, newText: @escaping ((String) -> ()), completion: ((String) -> ())? = nil) {
    var newUrls = urls
    print(urls.count)
    guard let url = newUrls.first else {
      completion?(testRes)
      return
    }

    Recognizer.recognizeRecord(at: url, in: locale) { text in
      newUrls.removeFirst()
      newText(" " + text)
      self.test(at: newUrls, in: locale, newText: newText)
    }
  }
  
  static func recognizeRecord(at urls:[URL], in locale:Locale, completion: ((String) -> ())? = nil)  {
    
    test(at: urls, in: locale) { text in
     
    }
  }
}
