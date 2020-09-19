//
//  ExpandAnimator.swift
//  GradeCheck
//
//  Created by Ivan Chau on 4/19/16.
//  Copyright © 2016 Ivan Chau. All rights reserved.
//

import Foundation
import UIKit

class ExpandAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    static var animator = ExpandAnimator()
    
    enum ExpandTransitingMode : Int {
        case present, dismiss
    }
    let presentDuration =  0.4
    let dismissDuration = 0.15
    
    var openingFrame : CGRect?
    var transitionMode : ExpandTransitingMode = .present
    
    var topView : UIView!
    var bottomView: UIView!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if (transitionMode == .present){
            return presentDuration
        }else{
            return dismissDuration
        }
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let fromViewFrame = fromViewController.view.frame;
        
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        print(containerView)
        
        if(transitionMode == .present){
            topView = fromViewController.view.resizableSnapshotView(from: fromViewFrame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsMake(openingFrame!.origin.y, 0, 0, 0))
            topView.frame = CGRect(x: 0,y: 0,width: fromViewFrame.width,height: openingFrame!.origin.y)
            
            containerView.addSubview(topView)
            
            bottomView = fromViewController.view.resizableSnapshotView(from: fromViewFrame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsMake(0, 0, fromViewFrame.height - openingFrame!.origin.y - openingFrame!.height, 0))
            bottomView.frame = CGRect(x: 0, y: openingFrame!.origin.y + openingFrame!.height, width: fromViewFrame.width, height: fromViewFrame.height - openingFrame!.origin.y - openingFrame!.height)
            
            containerView.addSubview(bottomView)
            
            let snapshotView = toViewController.view.resizableSnapshotView(from: fromViewFrame, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
            snapshotView?.frame = openingFrame!
            containerView.addSubview(snapshotView!)
            
            toViewController.view.alpha = 0.0
            containerView.addSubview(toViewController.view)
            UIView.animate(withDuration: presentDuration, animations: { () -> Void in
                
                self.topView.frame = CGRect(x: 0, y: -self.topView.frame.height, width: self.topView.frame.width, height: self.topView.frame.height)
                self.bottomView.frame = CGRect(x: 0, y: fromViewFrame.height, width: self.bottomView.frame.width, height: self.bottomView.frame.height)
                snapshotView?.frame = toViewController.view.frame
            },completion: { (finished) -> Void in
                snapshotView?.removeFromSuperview()
                toViewController.view.alpha = 1.0
                transitionContext.completeTransition(finished)
            })
        }else{
            let snapshotView = fromViewController.view.resizableSnapshotView(from: fromViewController.view.bounds,afterScreenUpdates:true, withCapInsets: UIEdgeInsets.zero)
            containerView.addSubview(snapshotView!)
            
            fromViewController.view.alpha = 0.0;
            
            UIView.animate(withDuration: dismissDuration, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.topView.frame = CGRect(x: 0,y: 0,width: self.topView.frame.width, height: self.topView.frame.height)
                self.bottomView.frame = CGRect(x: 0, y: fromViewController.view.frame.height - self.bottomView.frame.height,width: self.bottomView.frame.width, height: self.bottomView.frame.height)
                snapshotView?.frame = self.openingFrame!;
                }, completion: { (finished) in
                    snapshotView?.removeFromSuperview();
                    fromViewController.view.alpha = 1.0
                    transitionContext.completeTransition(finished)
            })
            
        }
    }
}
