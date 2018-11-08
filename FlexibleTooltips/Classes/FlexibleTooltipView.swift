//
//  Created by Chen-Hao Chiang on 08.11.18.
//  Copyright © 2018 Chen-Hao Chiang. All rights reserved.
//

import Foundation
import UIKit

protocol FlexibleTooltipDelegate: class {
  func tooltipTapped()
}

public class FlexibleTooltip: UIView {
  
  public var configuration = Configuration()
  
  private var arrowTip: CGPoint
  private var tipText = ""
  
  let textLayerAdjustment = CGFloat(2) //CATextLayer seems to add an extra 1 pixel to the height sometimes, hence the adjustment
  let root3 = CGFloat(3).squareRoot()
  let screenInset = CGFloat(10) // tooltips should not appear too close to the edges of the screen, hence the inset (padding)
  
  weak var delegate: FlexibleTooltipDelegate?
  
  lazy var textSize: CGSize = {
    [unowned self] in
    return getTextSize(text: self.tipText, font: self.configuration.drawing.font, width: self.configuration.positioning.maxWidth)
    }()
  
  lazy var frameSize: CGSize = {
    [unowned self] in
    return CGSize(width: self.textSize.width + self.configuration.positioning.hInset*2, height: self.textSize.height + self.configuration.positioning.vInset*2 + self.configuration.drawing.arrowHeight + self.textLayerAdjustment)
    }()
  
  // If the rectangle is out of or too close (screenInset) to the main screen's boundaries, it will be shifted
  // rectRightShift designates the amount that the rectangle needs to be shifted to the right
  // if the rectangle needs to be shifted to the left, the value will be negative
  lazy var rectRightShift: CGFloat = {
    [unowned self] in
    var currentBaseX: CGFloat = self.arrowTip.x - self.frameSize.width/2
    if currentBaseX < self.screenInset {
      return self.screenInset - currentBaseX
    }else if (currentBaseX + frameSize.width) > UIScreen.main.bounds.maxX - self.screenInset {
      return UIScreen.main.bounds.maxX - (currentBaseX + frameSize.width) - self.screenInset
    }else{
      return 0
    }
    }()
  
  // If the arrow is out of or too close (screenInset) to the main screen's boundaries, it will be shifted
  // arrowRightShift designates the amount that the arrow needs to be shifted to the right
  // if the arrow needs to be shifted to the left, the value will be negative
  lazy var arrowRightShift: CGFloat = {
    [unowned self] in
    let minX: CGFloat = self.arrowTip.x - self.configuration.drawing.arrowHeight
    let maxX: CGFloat = self.arrowTip.x + self.configuration.drawing.arrowHeight
    let arrowInset = self.screenInset + 2
    if minX < arrowInset {
      return arrowInset - minX
    }else if maxX > UIScreen.main.bounds.maxX - arrowInset {
      return UIScreen.main.bounds.maxX - maxX - arrowInset
    }else{
      return 0
    }
    }()
  
  // user can customise the tooltip by modifying the attributes
  public struct Configuration {
    public struct Drawing {
      public var arrowHeight         = CGFloat(10)
      public var arrowWidth          = CGFloat(10)
      public var foregroundColor     = UIColor.black
      public var backgroundColor     = UIColor.white
      public var arrowPosition       : arrowPosition = .top
      public var borderWidth         = CGFloat(0.5)
      public var borderColor         = UIColor.black
      public var font                = UIFont.systemFont(ofSize: 18)
    }
    
    public struct Positioning {
      public var hInset              = CGFloat(15)
      public var vInset              = CGFloat(15)
      public var maxWidth            = CGFloat(250)
    }
    
    public var drawing      = Drawing()
    public var positioning  = Positioning()
    
    public init() {}
  }
  
  private func getTextSize(text: String, font: UIFont, width: CGFloat) -> CGSize {
    let attributes = [NSAttributedStringKey.font : font]
    var textSize = text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
    
    textSize.width = ceil(textSize.width)
    textSize.height = ceil(textSize.height)
    
    if textSize.width < self.configuration.drawing.arrowHeight {
      textSize.width = self.configuration.drawing.arrowHeight
    }
    
    return textSize
  }
  
  public init(arrowTip: CGPoint, arrow arrowPosition: arrowPosition, maxWidth: CGFloat, text: String) {
    self.configuration.drawing.arrowPosition = arrowPosition
    self.arrowTip = arrowTip
    self.tipText = text
    self.configuration.positioning.maxWidth = maxWidth
    super.init(frame: CGRect.zero)
    backgroundColor = UIColor.clear
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func correctFrame() {
    switch self.configuration.drawing.arrowPosition {
    case .top:
      self.frame = CGRect(x: self.arrowTip.x - self.frameSize.width/2 + self.rectRightShift, y: self.arrowTip.y, width: self.frameSize.width, height: self.frameSize.height)
      break
    case .bottom:
      self.frame = CGRect(x: self.arrowTip.x - self.frameSize.width/2 + self.rectRightShift, y: self.arrowTip.y - self.frameSize.height, width: self.frameSize.width, height: self.frameSize.height)
      break
    }
  }
  
  //MARK: ANIMATIONS
  public func show(parentView: UIView) {
    // Set the correct frame
    self.correctFrame()
    
    parentView.addSubview(self)
    
    let animations : () -> () = {
      self.alpha = 1
    }
    
    UIView.animate(withDuration: 5, delay: 0, options: [.curveEaseInOut], animations: animations, completion: nil)
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(tipTapped))
    tap.delegate = self
    addGestureRecognizer(tap)
    
  }
  
  public func close() {
    dismiss()
  }
  
  @objc private func tipTapped(){
    //dismiss()
    self.delegate?.tooltipTapped()
  }
  
  private func dismiss(withCompletion completion: (() -> ())? = nil){
    UIView.animate(withDuration: 5, delay: 0, options: [.curveEaseInOut], animations: {
      self.alpha = 1
    }) { (finished) -> Void in
      completion?()
      self.removeFromSuperview()
      self.transform = CGAffineTransform.identity
    }
  }
  
  private func drawTextRect(base: CGPoint) {
    // Add text layer
    self.addTextLayer(base: base)
  }
  
  private func drawArrow(arrowPosition: arrowPosition){
    var arrowTip, arrowRight, arrowLeft: CGPoint!
    var maskAdjustment: CGFloat! // draw the arrow a little bigger to cover up the border line of the rectangle
    
    switch arrowPosition {
    case .top:
      // Ideally the arrow should be centered to the middle of the rectangle. However, if the rectangle needs to be shifted itself, the arrow won't be centered to the middle anymore. In order to maintain the arrow at the position specified by the user, it has to reverse the right(left) shift of the frame by substracting self.rectRightShift
      // self.arrowRightShift is used because the arrow might be too close to the edges
      arrowTip = CGPoint(x: self.frameSize.width/2 - self.rectRightShift + self.arrowRightShift, y: 0)
      arrowRight = CGPoint(x: arrowTip.x + self.configuration.drawing.arrowHeight, y: self.configuration.drawing.arrowHeight)
      arrowLeft = CGPoint(x: arrowTip.x - self.configuration.drawing.arrowHeight, y: self.configuration.drawing.arrowHeight)
      maskAdjustment = 2
      break
    case .bottom:
      arrowTip = CGPoint(x: self.frameSize.width/2 - self.rectRightShift + self.arrowRightShift, y: self.frameSize.height)
      arrowRight = CGPoint(x: arrowTip.x + self.configuration.drawing.arrowHeight, y: arrowTip.y - self.configuration.drawing.arrowHeight)
      arrowLeft = CGPoint(x: arrowTip.x - self.configuration.drawing.arrowHeight, y: arrowTip.y - self.configuration.drawing.arrowHeight)
      maskAdjustment = -2
      break
    }
    
    // add shahow layer
    let pathShadow = UIBezierPath()
    pathShadow.move(to: arrowRight)
    pathShadow.addLine(to: arrowTip)
    pathShadow.addLine(to: arrowLeft)
    self.addShadowLayer(path: pathShadow.cgPath)
    
    
    // add mask layer to cover up the shadow
    let pathMask = UIBezierPath()
    pathMask.move(to: CGPoint(x: arrowRight.x+2, y: arrowRight.y+maskAdjustment))
    pathMask.addLine(to: arrowTip)
    pathMask.addLine(to: CGPoint(x: arrowLeft.x-2, y: arrowLeft.y+maskAdjustment))
    pathMask.close()
    self.addTriangleLayer(path: pathMask.cgPath, color: self.configuration.drawing.backgroundColor.cgColor)
    
    // add border layer
    let pathBorder = UIBezierPath()
    pathBorder.move(to: arrowRight)
    pathBorder.addLine(to: arrowTip)
    pathBorder.addLine(to: arrowLeft)
    addBorderLayer(path: pathBorder.cgPath, color: self.configuration.drawing.borderColor.cgColor, width: self.configuration.drawing.borderWidth)
    
  }
  
  private func drawRectAndText(arrowPosition: arrowPosition){
    var p1, p2, p3, p4: CGPoint!
    var shiftDown = CGFloat(0), shiftUp = CGFloat(0)
    var textBase: CGPoint!
    
    switch arrowPosition {
    case .top:
      shiftDown = self.configuration.drawing.arrowHeight
      textBase = CGPoint(x: self.configuration.positioning.hInset, y: self.configuration.drawing.arrowHeight + self.configuration.positioning.vInset)
      break
    case .bottom:
      shiftUp = self.configuration.drawing.arrowHeight
      textBase = CGPoint(x: self.configuration.positioning.hInset, y: self.configuration.positioning.vInset)
      break
    }
    
    p1 = CGPoint(x: 0, y: shiftDown)
    p2 = CGPoint(x: self.frameSize.width, y: shiftDown)
    p3 = CGPoint(x: self.frameSize.width, y: self.frameSize.height - shiftUp)
    p4 = CGPoint(x: 0, y: self.frameSize.height - shiftUp)
    
    
    // create the path
    let path = UIBezierPath()
    path.move(to: p1)
    path.addLine(to: p2)
    path.addLine(to: p3)
    path.addLine(to: p4)
    path.close()
    path.fill()
    
    // Add shadow
    addShadowLayer(path: path.cgPath)
    
    // Add border
    addBorderLayer(path: path.cgPath, color: self.configuration.drawing.borderColor.cgColor, width: self.configuration.drawing.borderWidth)
    
    // Add text
    drawTextRect(base: textBase)
  }
  
  override public func draw(_ rect: CGRect) {
    drawRectAndText(arrowPosition: self.configuration.drawing.arrowPosition)
    drawArrow(arrowPosition: self.configuration.drawing.arrowPosition)
  }
  
  public enum arrowPosition {
    case top
    case bottom
  }
  
}

extension FlexibleTooltip: UIGestureRecognizerDelegate {
  
}

extension FlexibleTooltip {
  // functions that add CALayer
  
  private func addBorderLayer(path: CGPath, color: CGColor, width: CGFloat) {
    let borderLayer = CAShapeLayer()
    borderLayer.path = path // Reuse the Bezier path
    borderLayer.strokeColor = color
    borderLayer.fillColor = self.configuration.drawing.backgroundColor.cgColor
    borderLayer.lineWidth = width
    self.layer.addSublayer(borderLayer)
  }
  
  private func addShadowLayer(path: CGPath) {
    let shadowLayer = CAShapeLayer()
    shadowLayer.path = path
    shadowLayer.fillColor = self.configuration.drawing.backgroundColor.cgColor
    shadowLayer.shadowColor = UIColor.gray.cgColor
    shadowLayer.shadowOffset = CGSize.zero
    shadowLayer.shadowRadius = 5.0
    shadowLayer.shadowOpacity = 0.8
    self.layer.insertSublayer(shadowLayer, at: 0)
  }
  
  private func addTriangleLayer(path: CGPath, color: CGColor) {
    let triangleLayer = CAShapeLayer()
    triangleLayer.path = path
    triangleLayer.fillColor = color
    self.layer.addSublayer(triangleLayer)
  }
  
  private func addTextLayer(base: CGPoint) {
    let textLayer = CATextLayer()
    
    textLayer.frame = CGRect(x: base.x, y: base.y, width: self.textSize.width, height: self.textSize.height + 2)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
    
    let tipAttributes = [
      NSAttributedStringKey.font: self.configuration.drawing.font , // font
      NSAttributedStringKey.foregroundColor: self.configuration.drawing.foregroundColor, // text color
      NSAttributedStringKey.paragraphStyle : paragraphStyle
    ]
    
    let tipAttributedString = NSMutableAttributedString(string: self.tipText, attributes: tipAttributes)
    
    textLayer.string = tipAttributedString
    textLayer.backgroundColor = self.configuration.drawing.backgroundColor.cgColor
    textLayer.isWrapped = true
    textLayer.contentsScale = UIScreen.main.scale
    self.layer.addSublayer(textLayer)
  }
  
}

