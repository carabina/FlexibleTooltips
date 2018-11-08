# FlexibleTooltips

[![CI Status](https://img.shields.io/travis/chenhao.chiang@gmail.com/FlexibleTooltips.svg?style=flat)](https://travis-ci.org/chenhao.chiang@gmail.com/FlexibleTooltips)
[![Version](https://img.shields.io/cocoapods/v/FlexibleTooltips.svg?style=flat)](https://cocoapods.org/pods/FlexibleTooltips)
[![License](https://img.shields.io/cocoapods/l/FlexibleTooltips.svg?style=flat)](https://cocoapods.org/pods/FlexibleTooltips)
[![Platform](https://img.shields.io/cocoapods/p/FlexibleTooltips.svg?style=flat)](https://cocoapods.org/pods/FlexibleTooltips)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

# Setup with CocoaPods
* Add ```pod 'FlexibleTooltips'``` to your ```Podfile```
* Run ```pod install```
* Run ```open App.xcworkspace```

# Usage

## Creating a tooltip
To create a tooltip, you need to specify the coordinate of the arrow tip, the position of the arrow (at the top or the bottom of the tooltip rectangle), the maximum width of the tooltip rectangle and the text.

```swift
let tooltip = FlexibleTooltip(arrowTip: CGPoint(x: 50, y: 150), arrow: .bottom, maxWidth: CGFloat(200), text: "Hello world. This is the first tooltip.")
```

## Customise a tooltip
To customise a tooltip, change the values in `tooltip.configuration`.

```swift
tooltip.configuration.drawing.foregroundColor = UIColor.black
tooltip.configuration.drawing.backgroundColor = UIColor.lightGray
tooltip.configuration.drawing.borderColor = UIColor.gray
tooltip.configuration.drawing.borderWidth = 2
```

## FlexibleTooltipManager
Create a FlexibleTooltipManager to mange tooltips.

```swift
let tooltip1 = FlexibleTooltip(arrowTip: CGPoint(x: 50, y: 150), arrow: .bottom, maxWidth: CGFloat(200), text: "Hello world. This is the first tooltip.")

let tooltip2 = FlexibleTooltip(arrowTip: CGPoint(x: 150, y: 250), arrow: .bottom, maxWidth: CGFloat(200), text: "How about this? This is the second tooltip.")

let tooltip3 = FlexibleTooltip(arrowTip: CGPoint(x: 200, y: 200), arrow: .top, maxWidth: CGFloat(200), text: "This is the final tooltip. You're almost finished!")

let tooltipManager = FlexibleTooltipManager(view: self.view)

tooltipManager.addTooltip(tooltip1)
tooltipManager.addTooltip(tooltip2)
tooltipManager.addTooltip(tooltip3)
tooltipManager.startDisplayTips()
```

## Delegate methods
If you are using the FlexibleTooltipManager to mange tooltips, set the ViewController as FlexibleTooltipManagerDelegate and conform to the protocol.

```swift
extension ViewController: FlexibleTooltipManagerDelegate {
  func userDidFinishTips() {
    print("User saw all tips.")
  }

  func tooltipTapped() {
    tooltipManager.displayNextTip()
  }
}

```

## Installation

FlexibleTooltips is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FlexibleTooltips'
```

## Author

chenhao.chiang@gmail.com

## License

FlexibleTooltips is available under the MIT license. See the LICENSE file for more info.
