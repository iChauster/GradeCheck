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
}
