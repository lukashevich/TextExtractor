//
//  NewDocumentViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit
import XCDYouTubeKit

final class NewDocumentViewModel {
  
  enum ProcessStep {
    case start
    case recognized(String)
    case progress(CGFloat)
    case finish
  }
  
  var splittingHandlder: (() -> Void)?
  var processStepHandler: ((ProcessStep) -> Void)?
  var isDocumentReady: Bool = false
  var _locale: Locale {
    UserDefaults.standard.extractingLocale
  }
  
  private var _document: Document? {
    didSet {
      self.isDocumentReady = self._document != nil
    }
  }
  
  var fileUrl: URL? {
    didSet {
      guard let url = fileUrl else { return }
      AudioEditHelper.prepareFile(at: url) { urls in
        self._splittedSource = [urls[0],  urls[1], urls[2], urls[3], urls[4], urls[5]]
        DispatchQueue.main.async {
          self.splittingHandlder?()
        }
      }
    }
  }
  
  private var _recognizedTexts: [String] = []
  private var _splittedSource: [URL] = []
  
  private func _processFile() {
    guard !_splittedSource.isEmpty else { return }
    
    self._recognizedTexts = []
    
    DispatchQueue.main.async {
      self.processStepHandler?(.start)
    }
  
    let step = CGFloat(1.0 / Float(_splittedSource.count))
    Recognizer.test(at: _splittedSource, in: _locale) { text in
      DispatchQueue.main.async {
        self._recognizedTexts.append(text)
        DispatchQueue.main.async {
          self.processStepHandler?(.recognized(text))
          let progress = CGFloat(self._recognizedTexts.count) * step
          self.processStepHandler?(.progress(progress))
        }
        guard self._recognizedTexts.count == self._splittedSource.count else { return }
        self._finishProcessing()
      }
    }
  }
  
  func clearData() {
    fileUrl = nil
    _document = nil
    _recognizedTexts = []
    _splittedSource = []
  }
  
  func prepareForLocalize() {
    _document = nil
    _recognizedTexts = []
  }
  
  func startProcessing() {
    Recognizer.checkStatus { (authorized) in
      switch authorized {
      case true:  self._processFile()
      case false: break
      }
    }
  }
  
  func saveDocument() {
    _document?.createFile()
  }
  
  private func _finishProcessing() {
    self._document = Document(
      name: fileUrl?.deletingPathExtension().lastPathComponent ?? "",
      text: _recognizedTexts.joined(separator: " "),
      createdAt: Date(),
      modifiedAt: Date())
    
    DispatchQueue.main.async {
      self.processStepHandler?(.finish)
    }
  }
  
  func loadVideo() {
    //"https://www.youtube.com/watch?v=0ymRmQf5MAM"
        extractVideos(from: "iol8n3m88SA") { (dic) -> (Void) in
          print(dic.keys)
    //                let player = AVPlayer(url: URL(string: dic.values.first!)!)
    //                playerLayer.player = player
    //                playerLayer.player?.play()
                }
    
    //    XCDYouTubeClient.default().getVideoWithIdentifier("9bZkp7q19f0") { (video, error) in
    //      if let url = video?.streamURL {
    //        self.fileUrl = url
    ////        let test = AVURLAsset(url: url)
    ////        print(test)
    //      }
    //    }
    
//    let videoURL = "https://www.youtube.com/watch?v=0ymRmQf5MAM"
//    let url = NSURL(string: "http://www.youtubeinmp3.com/api/fetch/?format=JSON&video=\(videoURL)")
//    let sessionConfig = URLSessionConfiguration.default
//    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
//    let request = NSMutableURLRequest(url: url! as URL)
//    request.httpMethod = "GET"
//    
//    let task = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
//      if (error == nil) {
//        if let response = response as? HTTPURLResponse {
//          print("response=\(response)")
//          if response.statusCode == 200 {
//            if data != nil {
//              do {
//                let responseJSON =  try  JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary;
//                let urlString = responseJSON["link"] as! String
//                let directDownloadURL = NSURL(string: urlString)
//                
//                
//                print("!!!!", directDownloadURL)
//                // Call your method loadFileAsync
////                YourClass.loadFileAsync(directDownloadURL!, completion: { (path, error) -> Void in
////                  print(path)
////                })
////
//              }
//              catch let JSONError as Error {
//                print("\(JSONError)")
//              }
//              catch {
//                print("unknown error in JSON Parsing");
//              }
//              
//            }
//          }
//        }
//      }
//      else {
//        print("Failure: \(error!.localizedDescription)");
//      }
//    })
//    task.resume()
    
  }
}


extension String {
  var youtubeID: String? {
    let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
    
    let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    let range = NSRange(location: 0, length: count)
    
    guard let result = regex?.firstMatch(in: self, range: range) else {
      return nil
    }
    
    return (self as NSString).substring(with: result.range)
  }
}
