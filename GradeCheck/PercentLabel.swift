//
//  PercentLabel.swift
//  GradeCheck
//
//  Created by Ivan Chau on 4/20/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import Foundation
import UIKit

enum PercentLabelAnimationCurve {
    case Linear
    case EaseIn
    case EaseOut
    case EaseInOut
}

class PercentLabel: UILabel {
    
    // TODO: String Formats
    
    let counterRate: Float = 3.0
    var animationCurve: PercentLabelAnimationCurve = .EaseInOut
    var startingValue: CGFloat = 0
    var destinationValue: CGFloat = 0
    var progress: NSTimeInterval = NSTimeInterval()
    var lastUpdate: NSTimeInterval = NSTimeInterval()
    var totalTime: NSTimeInterval = NSTimeInterval()
    var timer: NSTimer = NSTimer()
    
    func count(from startValue: CGFloat, to endValue: CGFloat, duration:NSTimeInterval) {
        startingValue = startValue
        destinationValue = endValue
        timer.invalidate()
        
        if duration <= 0.0 {
            self.text = String(format:"%.0lf%%", Double(endValue))
            return
        } else {
            progress = 0
            totalTime = duration
            lastUpdate = NSDate.timeIntervalSinceReferenceDate()
            
            let timer = NSTimer(timeInterval: (1.0/30.0), target: self, selector: #selector(PercentLabel.updateValue), userInfo: nil, repeats: true)
            
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: UITrackingRunLoopMode)
            self.timer = timer
        }
    }
    
    func updateValue(timer: NSTimer) {
        let now = NSDate.timeIntervalSinceReferenceDate()
        
        progress = progress + now - lastUpdate
        lastUpdate = now
        
        if progress >= totalTime {
            self.timer.invalidate()
            progress = totalTime
        }
        
        text = String(format:"%.0lf%%", Double(currentValue()))
    }
    
    func update(t: Float) -> Float {
        var a = t;
        switch animationCurve {
        case .Linear:
            return a
        case .EaseIn:
            return powf(a, counterRate)
        case .EaseOut:
            return 1.0 - powf((1.0 - a), counterRate)
        case .EaseInOut:
            var sign: Int = 1
            let r: Int = Int(counterRate)
            
            if (r % 2 == 0) {
                sign = -1
            }
            
            a *= 2
            
            if (a < 1) {
                return 0.5 * powf(a, counterRate)
            } else {
                return Float(sign) * Float(0.5) * (powf(a - 2, counterRate) + Float(sign * 2))
            }
        }
    }
    
    func currentValue() -> CGFloat {
        if progress >= totalTime {
            return destinationValue
        }
        
        let percent: Float = Float(progress / totalTime)
        let updateVal: Float = self.update(percent)
        
        return CGFloat(Float(startingValue) + updateVal * Float(destinationValue - startingValue))
    }
}