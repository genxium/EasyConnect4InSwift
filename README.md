# EasyConnect4InSwift

***What is this?***

![Alt text](http://7xljmm.dl1.z0.glb.clouddn.com/ConnectFour.png "Game Screenshot")

This project builds a simple [Connect4/FourInARow game](https://en.wikipedia.org/wiki/Connect_Four), it's inspired by [an Apple Developer sample](https://developer.apple.com/library/ios/samplecode/FourInARow) for GameplayKit minmax strategist.

However there're several significant differences other than the use of Swift (thus shorter code length) instead of Objective-C.

1. Additional 'ChipNode' view class for better readibility.
2. Unified view-controller entry/method for either human or AI moves.  
3. Temporarily removed the strategist instance.

The state automata for 'Board' is not yet complicated enough to take a place in the codes at the moment :)

***How to install***

This project requires the following OS, IDE and device/simulator to build & run

1. OSX 10.11+
2. XCode 7.2+
3. device/simulator of iOS 9.0+

Once the requirements above are all satisfied, you can build & run it by 

1. shell> git clone https://github.com/genxium/EasyConnect4InSwift
2. shell> cd /path/to/project_root # [here](https://github.com/genxium/EasyConnect4InSwift)
3. shell> open ConnectFour.xcodeproj
4. build & run by XCode

***AI trigger***

In [view controller file](https://github.com/genxium/EasyConnect4InSwift/ConnectFour/GameViewController.swift), set 

```swift
  var blackByAI = true
```

to turn on the AI as black player, or

```swift
  var blackByAI = false
```

to turn it off.
