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
        case Present, Dismiss
    }
    let presentDuration =  0.4
    let dismissDuration = 0.15
    
    var openingFrame : CGRect?
    var transitionMode : ExpandTransitingMode = .Present
    
    var topView : UIView!
    var bottomView: UIView!
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if (transitionMode == .Present){
            return presentDuration
        }else{
            return dismissDuration
        }
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromViewFrame = fromViewController.view.frame;
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        
        if(transitionMode == .Present){
            topView = fromViewController.view.resizableSnapshotViewFromRect(fromViewFrame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsMake(openingFrame!.origin.y, 0, 0, 0))
            topView.frame = CGRectMake(0,0,fromViewFrame.width,openingFrame!.origin.y)
            
            containerView?.addSubview(topView)
            
            bottomView = fromViewController.view.resizableSnapshotViewFromRect(fromViewFrame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsMake(0, 0, fromViewFrame.height - openingFrame!.origin.y - openingFrame!.height, 0))
            bottomView.frame = CGRectMake(0, openingFrame!.origin.y + openingFrame!.height, fromViewFrame.width, fromViewFrame.height - openingFrame!.origin.y - openingFrame!.height)
            
            containerView?.addSubview(bottomView)
            
            let snapshotView = toViewController.view.resizableSnapshotViewFromRect(fromViewFrame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
            snapshotView.frame = openingFrame!
            containerView!.addSubview(snapshotView)
            
            toViewController.view.alpha = 0.0
            containerView!.addSubview(toViewController.view)
            
            UIView.animateWithDuration(presentDuration, animations: { () -> Void in
                
                self.topView.frame = CGRectMake(0, -self.topView.frame.height, self.topView.frame.width, self.topView.frame.height)
                self.bottomView.frame = CGRectMake(0, fromViewFrame.height, self.bottomView.frame.width, self.bottomView.frame.height)
                snapshotView.frame = toViewController.view.frame
            },completion: { (finished) -> Void in
                snapshotView.removeFromSuperview()
                toViewController.view.alpha = 1.0
                transitionContext.completeTransition(finished)
            })
        }else{
            let snapshotView = fromViewController.view.resizableSnapshotViewFromRect(fromViewController.view.bounds,afterScreenUpdates:true, withCapInsets: UIEdgeInsetsZero)
            containerView!.addSubview(snapshotView)
            
            fromViewController.view.alpha = 0.0;
            
            UIView.animateWithDuration(dismissDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.topView.frame = CGRectMake(0,0,self.topView.frame.width, self.topView.frame.height)
                self.bottomView.frame = CGRectMake(0, fromViewController.view.frame.height - self.bottomView.frame.height,self.bottomView.frame.width, self.bottomView.frame.height)
                snapshotView.frame = self.openingFrame!;
                }, completion: { (finished) in
                    snapshotView.removeFromSuperview();
                    fromViewController.view.alpha = 1.0
                    transitionContext.completeTransition(finished)
            })
            
        }
    }
}