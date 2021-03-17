//
//  NewDocumentViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 15.02.2021.
//

import Foundation
import UIKit
import XCDYouTubeKit
import VisionKit
import Vision

final class NewDocumentViewModel {
  
  enum ProcessStep {
    case start
    case recognized(String)
    case progress(CGFloat)
    case finish(Document?)
  }
  
  private var _textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
  private let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
  
  var processStepHandler: ((ProcessStep) -> Void)?
  var isDocumentReady: Bool = false
  var _locale: Locale {
    UserDefaults.standard.extractingLocale
  }
  
  var document: Document? {
    didSet {
      self.isDocumentReady = self.document != nil
    }
  }
  
  var fileUrl: URL? {
    didSet {
      guard let url = fileUrl else { return }
      AudioEditHelper.prepareFile(at: url) { urls in
        Recognizer.enableRecognizing()
        self._splittedSource = urls
        self.startProcessing()
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
    let startDate = Date()
    Recognizer.recognizeMedia(at: _splittedSource, in: _locale) { text in
      DispatchQueue.main.async {
        self._recognizedTexts.append(text)
        DispatchQueue.main.async {
          self.processStepHandler?(.recognized(text))
          let progress = CGFloat(self._recognizedTexts.count) * step
          self.processStepHandler?(.progress(progress))
        }
        guard self._recognizedTexts.count == self._splittedSource.count else { return }
        self._finishProcessing(source: .media, text: self._recognizedTexts.joined(separator: " "))
      }
    }
    
//    Recognizer.recognizeMediaConcurrently(at: _splittedSource, in: _locale) { (newText, index) in
//      print("CONCURRENT", index, newText)
//    }
  }
  
  func clearData() {
    fileUrl = nil
    document = nil
    _recognizedTexts = []
    _splittedSource = []
  }
  
  func stopExtracting() {
    Recognizer.stopRecognizing()
  }
  
  func prepareForLocalize() {
    document = nil
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
 
  private func _finishProcessing(source: DocumentSource, text: String) {
    switch source {
    case .media:
      self.document = Document(
        name: fileUrl?.deletingPathExtension().lastPathComponent ?? "",
        text: text,
        createdAt: Date(),
        modifiedAt: Date(),
        source: source)
    case .photo:
      self.document = Document(
        name: "New",
        text: text,
        createdAt: Date(),
        modifiedAt: Date(),
        source: source)
    }
    
    DispatchQueue.main.async {
      self.processStepHandler?(.finish(self.document))
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

extension NewDocumentViewModel {
  func processImage(_ image: UIImage) {
    self.recognizeTextInImage(image)
  }
  
  func recognizeTextInImage(_ image: UIImage) {
    guard let cgImage = image.cgImage else { return }
    
    DispatchQueue.main.async {
      self.processStepHandler?(.start)
    }
    
    textRecognitionWorkQueue.async {
      let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
      do {
        try requestHandler.perform([self._textRecognitionRequest])
      } catch {
        print(error)
      }
    }
  }
  
  func setupVision() {
    self._textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
      
      var detectedText = ""
      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { return }
        
        detectedText += topCandidate.string
        detectedText += "\n"
        
        DispatchQueue.main.async {
          self.processStepHandler?(.recognized(topCandidate.string))
        }
      }
      
      DispatchQueue.main.async {
        self._finishProcessing(source: .photo, text: detectedText)
      }
    }
    
    self._textRecognitionRequest.recognitionLevel = .accurate
  }
  
  func compressedImage(_ originalImage: UIImage) -> UIImage {
    guard let imageData = originalImage.jpegData(compressionQuality: 1),
          let reloadedImage = UIImage(data: imageData) else {
      return originalImage
    }
    return reloadedImage
  }
}
