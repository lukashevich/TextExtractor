//
//  CMTime+Extensions.swift
//  TextExtactor
//
//  Created by Oleksandr Lukashevych on 10.03.2021.
//

import AVFoundation

extension CMTime {
  var seconds: CGFloat {
    CGFloat(CMTimeGetSeconds(self))
  }
  
  var miliseconds: CGFloat {
    CGFloat(CMTimeGetSeconds(self) * 1000)
  }
}
