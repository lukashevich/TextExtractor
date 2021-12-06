//
//  Snowy.swift
//  InvoiceMaker
//
//  Created by Lucas on 17.12.2020.
//  Copyright © 2020 Saldo Apps. All rights reserved.
//

import UIKit
import QuartzCore

protocol Snowy {
  func letItSnow()
}

extension Snowy where Self: UIViewController {

  private var _emitterStartPosition: CGPoint {
    return CGPoint(x: view.frame.width / 2.0, y: -view.frame.height / 2)
  }
  
  func letItSnow() {
    let snowEmitterLayer = CAEmitterLayer()
    snowEmitterLayer.emitterPosition = _emitterStartPosition

    snowEmitterLayer.emitterShape = CAEmitterLayerEmitterShape.line
    snowEmitterLayer.beginTime = CACurrentMediaTime()
    snowEmitterLayer.timeOffset = 10.0
    
    let snowflakesImages = [ #imageLiteral(resourceName: "snowflake_4"), #imageLiteral(resourceName: "snowflake_5"), #imageLiteral(resourceName: "snowflake_6"), #imageLiteral(resourceName: "snowflake_3")]
    
    snowEmitterLayer.emitterCells = snowflakesImages.map {
      let flakeEmitterCell = _newSnowflake(with: $0)
      flakeEmitterCell.velocity = 32.0
      flakeEmitterCell.velocityRange = 10
      flakeEmitterCell.yAcceleration = CGFloat.random(in: 7...14)
      return flakeEmitterCell
    }
    self.view.layer.addSublayer(snowEmitterLayer)
    self.view.clipsToBounds = true
  }
  
  private func _newSnowflake(with image: UIImage) -> CAEmitterCell {
    let flakeCell = CAEmitterCell()
    flakeCell.contents = image.cgImage
    flakeCell.emissionRange = .pi * 2
    flakeCell.lifetime = 20.0
    flakeCell.birthRate = 10
    flakeCell.scale = CGFloat.random(in:  0.15...0.36)
    flakeCell.scaleRange = CGFloat.random(in:  0.4...0.6)
    return flakeCell
  }
}
