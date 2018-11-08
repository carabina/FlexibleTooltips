//
//  Created by Chen-Hao Chiang on 08.11.18.
//  Copyright © 2018 Chen-Hao Chiang. All rights reserved.
//

import Foundation
import UIKit

protocol FlexibleTooltipManagerDelegate: class {
  func userDidFinishTips()
  func tooltipTapped()
}

public class FlexibleTooltipManager: FlexibleTooltipDelegate {
  func tooltipTapped() {
    delegate?.tooltipTapped()
  }
  
  private var tooltips: [FlexibleTooltip] = []
  weak var delegate: FlexibleTooltipManagerDelegate?
  private var parentView: UIView!
  
  init(view: UIView) {
    self.parentView = view
  }
  
  public func displayNextTip(){
    if tooltips.count != 0 {
      close()
      tooltips.remove(at: 0)
    }
    startDisplayTips()
  }
  
  public func addTooltip(_ tooltip: FlexibleTooltip){
    tooltips.append(tooltip)
  }
  
  public func startDisplayTips() {
    if !tooltips.isEmpty {
      tooltips[0].delegate = self
      tooltips[0].show(parentView: self.parentView)
    } else { //User has seen all tips
      delegate?.userDidFinishTips()
    }
  }
  
  private func close() {
    if !tooltips.isEmpty {
      tooltips[0].close()
    }
  }
}

