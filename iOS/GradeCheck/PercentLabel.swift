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
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

class PercentLabel: UILabel {
    
    // TODO: String Formats
    
    let counterRate: Float = 3.0
    var animationCurve: PercentLabelAnimationCurve = .easeInOut
    var startingValue: CGFloat = 0
    var destinationValue: CGFloat = 0
    var progress: TimeInterval = TimeInterval()
    var lastUpdate: TimeInterval = TimeInterval()
    var totalTime: TimeInterval = TimeInterval()
    var timer: Timer = Timer()
    
    func count(from startValue: CGFloat, to endValue: CGFloat, duration:TimeInterval) {
        startingValue = startValue
        destinationValue = endValue
        timer.invalidate()
        
        if duration <= 0.0 {
            self.text = String(format:"%.0lf%%", Double(endValue))
            return
        } else {
            progress = 0
            totalTime = duration
            lastUpdate = Date.timeIntervalSinceReferenceDate
            
            let timer = Timer(timeInterval: (1.0/30.0), target: self, selector: #selector(PercentLabel.updateValue), userInfo: nil, repeats: true)
            
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            RunLoop.main.add(timer, forMode: RunLoopMode.UITrackingRunLoopMode)
            self.timer = timer
        }
    }
    
    @objc func updateValue(_ timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        
        progress = progress + now - lastUpdate
        lastUpdate = now
        
        if progress >= totalTime {
            self.timer.invalidate()
            progress = totalTime
        }
        
        text = String(format:"%.0lf%%", Double(currentValue()))
    }
    
    func update(_ t: Float) -> Float {
        var a = t;
        switch animationCurve {
        case .linear:
            return a
        case .easeIn:
            return powf(a, counterRate)
        case .easeOut:
            return 1.0 - powf((1.0 - a), counterRate)
        case .easeInOut:
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
