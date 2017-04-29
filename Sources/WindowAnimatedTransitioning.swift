//
//  WindowAnimatedTransitioning.swift
//  WindowController
//
//  Created by Martin Banas on 12/03/17.
//  Copyright © 2017 WindowController Contributors. All rights reserved.
//

import Foundation

public protocol WindowAnimatedTransitioning: class {
    
    func transitionDuration(transitionContext: WindowContextTransitioning?) -> TimeInterval
    
    func animateTransition(transitionContext: WindowContextTransitioning)
    
    func animationEnded(transitionCompleted: Bool)
}

