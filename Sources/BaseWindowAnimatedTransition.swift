//
//  BaseWindowAnimatedTransition.swift
//  WindowController
//
//  Created by Martin Banas on 12/03/17.
//  Copyright © 2017 WindowController Contributors. All rights reserved.
//

import UIKit

class BaseWindowAnimatedTransition: WindowAnimatedTransitioning {
    
    private let duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    // MARK: WindowAnimatedTransitioning
    
    func transitionDuration(transitionContext: WindowContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated() == true ? duration : 0
    }
    
    func animateTransition(transitionContext: WindowContextTransitioning) {
        let toWindow = transitionContext.window(for: WindowTransitionContextToWindowKey)!
        let fromWindow = transitionContext.window(for: WindowTransitionContextFromWindowKey)!
        
        toWindow.alpha = 0
        toWindow.rootViewController?.view.layoutIfNeeded()

        if transitionContext.isAnimated() {
            UIView.animate(withDuration: transitionDuration(transitionContext: transitionContext), animations: { () -> Void in
                fromWindow.alpha = 0
                toWindow.alpha = 1

            }) { (done) -> Void in
                if !done {
                    toWindow.alpha = 1
                }

                let transitionCompleted = !transitionContext.isCancelled()
                transitionContext.completeTransition(didComplete: transitionCompleted)
                self.animationEnded(transitionCompleted: transitionCompleted)
            }

        } else {
            fromWindow.alpha = 0
            toWindow.alpha = 1
            
            let transitionCompleted = !transitionContext.isCancelled()
            transitionContext.completeTransition(didComplete: transitionCompleted)
            animationEnded(transitionCompleted: transitionCompleted)
        }
    }
    
    func animationEnded(transitionCompleted: Bool) {
        // Not implemented in base class
    }
}
