//
//  Created by Chen-Hao Chiang on 08.11.18.
//  Copyright © 2018 Chen-Hao Chiang. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, FlexibleTooltipManagerDelegate {
  var tooltipManager : FlexibleTooltipManager!
  
  func userDidFinishTips() {
    print("User saw all tips.")
  }
  
  func tooltipTapped() {
    tooltipManager.displayNextTip()
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    
    tooltipManager = FlexibleTooltipManager(view: self.view)
    tooltipManager.delegate = self
    
    let tooltip1 = FlexibleTooltip(arrowTip: CGPoint(x: 50, y: 150), arrow: .bottom, maxWidth: CGFloat(200), text: "Hello world. This is the first tooltip.")
    tooltip1.configuration.drawing.foregroundColor = UIColor.black
    tooltip1.configuration.drawing.backgroundColor = UIColor.lightGray
    tooltip1.configuration.drawing.borderColor = UIColor.gray
    tooltip1.configuration.drawing.borderWidth = 2
    
    let tooltip2 = FlexibleTooltip(arrowTip: CGPoint(x: 150, y: 250), arrow: .bottom, maxWidth: CGFloat(200), text: "How about this? This is the second tooltip.")
    tooltip2.configuration.drawing.foregroundColor = UIColor.yellow
    tooltip2.configuration.drawing.backgroundColor = UIColor.blue
    tooltip2.configuration.drawing.borderColor = UIColor.blue
    tooltip2.configuration.drawing.borderWidth = 1
    
    let tooltip3 = FlexibleTooltip(arrowTip: CGPoint(x: 200, y: 200), arrow: .top, maxWidth: CGFloat(200), text: "This is the final tooltip. You're almost finished!")
    tooltip3.configuration.drawing.foregroundColor = UIColor.red
    tooltip3.configuration.drawing.backgroundColor = UIColor.orange
    tooltip3.configuration.drawing.borderColor = UIColor.white
    tooltip3.configuration.drawing.borderWidth = 3
    
    tooltipManager.addTooltip(tooltip1)
    tooltipManager.addTooltip(tooltip2)
    tooltipManager.addTooltip(tooltip3)
    tooltipManager.startDisplayTips()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
}

