//
//  WebShellTrackpadGestures.swift
//  WebShell
//
//  Created by Wesley de Groot on 20-04-16.
//  Copyright © 2018 WebShell. All rights reserved.
//

import AppKit
import Foundation
import WebKit

/**
 @wdg: This extension will support the swipe gestures
 Issue: #44
 */
extension WSViewController: NSGestureRecognizerDelegate {
    /**
     WSinitSwipeGestures
     
     Initialize Swipe Gestures!!!
     
     @wdg #44: Support Trackpad gestures
     */
    func WSinitSwipeGestures() {
        mainWebview.acceptsTouchEvents = true
        self.view.acceptsTouchEvents = true
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(with event: NSEvent) {
        twoFingersTouches = GestureUtils.twoFingersTouches(mainWebview, event)
    }
    
    override func touchesMoved(with event: NSEvent) {
        let swipeType: SwipeType = (settings?.navigateViaTrackpad ?? true) ? GestureUtils.swipe(mainWebview, event, twoFingersTouches) : .none
        if swipeType == .right {
            if mainWebview.canGoForward {
                if mainWebview.isLoading {
                    mainWebview.stopLoading(nil)
                }
                mainWebview.goForward(nil)
            }
        } else if swipeType == .left {
            if mainWebview.canGoBack {
                if mainWebview.isLoading {
                    mainWebview.stopLoading(nil)
                }
                mainWebview.goBack(nil)
            }
        }
    }
}

enum SwipeType {
    case left, right, none
}

class GestureUtils {
    /**
     * To avoid duplicate code we could extract the content of this method into an GestureUtils method. Return nil if there isn't 2 touches and set the array only if != nil
     */
    static func twoFingersTouches(_ view: NSView, _ event: NSEvent) -> [String: NSTouch]? {
        var twoFingersTouches: [String: NSTouch]?
        if event.type == NSEvent.EventType.gesture {
            let touches: Set<NSTouch> = event.touches(matching: NSTouch.Phase.any, in: view)
            if touches.count == 2 {
                for touch in touches {
                    twoFingersTouches?["\(touch.identity)"] = touch
                }
            }
        }

        if let touches = twoFingersTouches {
            return touches
        }

        return [String: NSTouch]()
    }
    
    /**
     * Detects 2 finger (left/right) swipe gesture
     * NOTE: either of 3 enums is returned: .leftSwipe, .rightSwipe .none
     * TODO: also make up and down swipe detectors, and do more research into how this could be done easier. Maybe you even have some clues in the notes about gestures etc.
     * Conceptually:
     * 1. Record 2 .began touchEvents
     * 2. Record 2 .ended touchEvents
     * 3. Measure the distance between .began and .ended and assert if it is within threshold
     */
    static func swipe(_ view: NSView, _ event: NSEvent, _ twoFingersTouches: [String: NSTouch]?) -> SwipeType {
        let endingTouches: Set<NSTouch> = event.touches(matching: NSTouch.Phase.ended, in: view)
        if endingTouches.count > 0 && twoFingersTouches != nil {
            let beginningTouches: [String: NSTouch] = twoFingersTouches!
            var magnitudes: [CGFloat] = []
            for endingTouch in endingTouches {
                let beginningTouch: NSTouch? = beginningTouches["\(endingTouch.identity)"]
                if beginningTouch == nil {
                    continue
                }
                let magnitude: CGFloat = endingTouch.normalizedPosition.x - beginningTouch!.normalizedPosition.x
                magnitudes.append(magnitude)
            }
            var sum: CGFloat = 0
            for magnitude in magnitudes {
                sum += magnitude
            }
            let absoluteSum: CGFloat = abs(sum)
            let kSwipeMinimumLength: CGFloat = 0.1
            if absoluteSum < kSwipeMinimumLength {
                return .none
            }
            if sum > 0 {
                return .right
            } else {
                return .left
            }
        }
        return .none
    }
}
