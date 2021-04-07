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
  
  static func recognizeMedia(at url:URL, in locale:Locale, completion: ((String) -> ())? = nil)  {
    
    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
      print("Speech recognition not available for specified locale")
      return
    }
    
    if !recognizer.isAvailable {
      print("Speech recognition not currently available")
      return
    }
    
    let request = SFSpeechURLRecognitionRequest(url: url)
    request.requiresOnDeviceRecognition = true
    
    recognizer.recognitionTask(with: request) { (result, error) in
      guard let result = result else {
        completion?("")
        
        print("SFSpeechRecognizer error", error, recognizer.isAvailable)
        return
      }
      if result.isFinal {
        print("Speech in the file is \(result.bestTranscription.formattedString)")
        completion?(result.bestTranscription.formattedString)
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
        
        Recognizer.recognizeMedia(at: url, in: locale) { text in
          newText(text, index)
          
          result[index] = text
          
          if result.count == urls.count {
            print("TEXT", result.map(\.value))
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
    
    Recognizer.recognizeMedia(at: url, in: locale) { text in
      guard !_stopped else { return }
      newUrls.removeFirst()
      if !text.isEmpty {
        newText(text + ", ")
      }
      self.recognizeMedia(at: newUrls, in: locale, newText: newText)
    }
  }
  
  static func enableRecognizing() {
    self._stopped = false
  }
  
  static func stopRecognizing() {
    self._stopped = true
  }
  
  //  static func recognizeRecord(at urls:[URL], in locale:Locale, completion: ((String) -> ())? = nil)  {
  //
  //    recognizeMedia(at: urls, in: locale) { text in
  //
  //    }
  //  }
}
