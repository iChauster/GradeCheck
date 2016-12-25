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
    let offset = CGPoint(x: -20, y: -20)
    var startTransform = CATransform3DIdentity
    startTransform = CATransform3DRotate(CATransform3DIdentity,
        rotationRadians, 0.0, 0.0, 1.0)
    startTransform = CATransform3DTranslate(startTransform, offset.x, offset.y, 0.0)
    
    return startTransform
}()
let CellAnimationStartSlide:CATransform3D = {
    var startTransform = CATransform3DIdentity
    startTransform = CATransform3DTranslate(startTransform,0,50,0);
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
    keyFrames.values = [NSValue(caTransform3D:CATransform3DIdentity),
        NSValue(caTransform3D:grow),
        NSValue(caTransform3D:shrinklit)]
    keyFrames.keyTimes = [0.0,0.4,0.6];
    keyFrames.duration = 0.4
    keyFrames.beginTime = CACurrentMediaTime() + 0.05;
    keyFrames.timingFunction = CAMediaTimingFunction(name : kCAMediaTimingFunctionEaseIn)
    
    keyFrames.fillMode = kCAFillModeBackwards
    return keyFrames;
}()
class CellAnimation {
    // placeholder for things to come -- only fades in for now
    
    class func animate(_ cell:UITableViewCell) {
        /* fade
        let view = cell.contentView
        view.layer.opacity = 0.1
        UIView.animateWithDuration(1.4) {
        view.layer.opacity = 1
        }*/
        let view = cell.contentView
        
        view.layer.transform = CellAnimationStartTransform
        view.layer.opacity = 0.8
        
        UIView.animate(withDuration: 0.4, animations: {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1
        }) 
    }
    class func slide(_ cell:UITableViewCell){
        let view = cell.contentView;
        view.layer.transform = CellAnimationStartSlide
        view.layer.opacity = 0.8;
        
        UIView.animate(withDuration: 0.4, animations: { 
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1;
        }) 
    }
    class func growAndShrink(_ view:UIView){
        UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0, animations: { () -> Void in
                view.layer.transform = CATransform3DIdentity
            })
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.4, animations: { () -> Void in
                view.layer.transform = grow
            })
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6, animations: { () -> Void in
                view.layer.transform = shrink
            })
            }, completion:{finshed in
                print("finished");
        });
        
    }
}
