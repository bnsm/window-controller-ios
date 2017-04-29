//
//  WindowContextTransitioning.swift
//  WindowController
//
//  Created by Martin Banas on 12/03/17.
//  Copyright © 2017 WindowController Contributors. All rights reserved.
//

import UIKit

public let WindowTransitionContextFromWindowKey = "WindowTransitionContextFromWindowKey"

public let WindowTransitionContextToWindowKey = "WindowTransitionContextToWindowKey"

public protocol WindowContextTransitioning: class {
    
    var completion: ((_ didComplete: Bool) -> Void)? { get set }
    
    func isAnimated() -> Bool
    
    func isInteractive() -> Bool
    
    func window(for key: String) -> UIWindow?
    
    func completeTransition(didComplete: Bool)
    
    func isCancelled() -> Bool
    
    func cancel()
}
