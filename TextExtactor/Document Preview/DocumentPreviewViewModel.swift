//
//   DocumentPreviewViewModel.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 22.02.2021.
//

import Foundation

enum PreviewOpenType {
  case mediaDoc(Document)
  case textDoc(Document)
}
struct DocumentPreviewViewModel {
  var document: Document
  let isNew: Bool
  let timeline: [TranscriptTimelineItem]

  init(document: Document, isNew: Bool, timeline: [TranscriptTimelineItem]? = nil) {
    self.document = document
    self.isNew = isNew
    self.timeline = timeline ?? document.timeline
  }
}
