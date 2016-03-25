//
//  CellAnimation.swift
//  GradeCheck
//
//  Created by Ivan Chau on 2/29/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

let CellAnimationStartTransform:CATransform3D = {
    let rotationDegrees: CGFloat = -15.0
    let rotationRadians: CGFloat = rotationDegrees * (CGFloat(M_PI)/180.0)
    let offset = CGPointMake(-20, -20)
    var startTransform = CATransform3DIdentity
    startTransform = CATransform3DRotate(CATransform3DIdentity,
        rotationRadians, 0.0, 0.0, 1.0)
    startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0)
    
    return startTransform
}()
let grow:CATransform3D = {
    var grow = CATransform3DIdentity;
    grow = CATransform3DScale(grow,1.2,1.2,1.2);
    return grow;
}()
let shrink: CATransform3D = {
    var shrinklit = CATransform3DIdentity;
    shrinklit = CATransform3DScale(shrinklit,0.7,0.7,0.7);
    return shrinklit
}()
let ShrinkExplodeStartTransform:CAKeyframeAnimation = {
    var grow = CATransform3DIdentity;
    grow = CATransform3DScale(grow,1.5,1.5,1.5);
    var shrinklit = CATransform3DIdentity
    shrinklit = CATransform3DScale(shrinklit,0.01,0.01,0.01)
    
    let keyFrames = CAKeyframeAnimation(keyPath:"transform")
    keyFrames.values = [NSValue(CATransform3D:CATransform3DIdentity),
        NSValue(CATransform3D:grow),
        NSValue(CATransform3D:shrinklit)]
    keyFrames.keyTimes = [0.0,0.4,0.6];
    keyFrames.duration = 0.4
    keyFrames.beginTime = CACurrentMediaTime() + 0.05;
    keyFrames.timingFunction = CAMediaTimingFunction(name : kCAMediaTimingFunctionEaseIn)
    
    keyFrames.fillMode = kCAFillModeBackwards
    return keyFrames;
}()
class CellAnimation {
    // placeholder for things to come -- only fades in for now
    
    class func animate(cell:UITableViewCell) {
        /* fade
        let view = cell.contentView
        view.layer.opacity = 0.1
        UIView.animateWithDuration(1.4) {
        view.layer.opacity = 1
        }*/
        let view = cell.contentView
        
        view.layer.transform = CellAnimationStartTransform
        view.layer.opacity = 0.8
        
        UIView.animateWithDuration(0.4) {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }
    }
    class func growAndShrink(view:UIView){
        UIView.animateKeyframesWithDuration(0.4, delay: 0.0, options: .CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0, animations: { () -> Void in
                view.layer.transform = CATransform3DIdentity
            })
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.4, animations: { () -> Void in
                view.layer.transform = grow
            })
            UIView.addKeyframeWithRelativeStartTime(0.4, relativeDuration: 0.6, animations: { () -> Void in
                view.layer.transform = shrink
            })
            }, completion:{finshed in
                print("finished");
        });
        
    }
}
