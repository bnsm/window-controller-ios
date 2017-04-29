//
//  BaseWindowContextTransition.swift
//  WindowController
//
//  Created by Martin Banas on 12/03/17.
//  Copyright © 2017 WindowController Contributors. All rights reserved.
//

import UIKit

class BaseWindowContextTransition: WindowContextTransitioning {
    
    var completion: ((_ didComplete: Bool) -> Void)?
    let animated: Bool

    private let windows: [String: UIWindow]
    private var cancelled = false
    
    init(fromWindow: UIWindow, toWindow: UIWindow, animated: Bool) {
        self.windows = [WindowTransitionContextFromWindowKey: fromWindow, WindowTransitionContextToWindowKey: toWindow]
        self.animated = animated
    }
    
    // MARK: WindowContextTransitioning
    
    func isAnimated() -> Bool {
        return true
    }
    
    func isInteractive() -> Bool {
        return false
    }
    
    func window(for key: String) -> UIWindow? {
        return windows[key]
    }
    
    func completeTransition(didComplete: Bool) {
        completion?(didComplete)
    }
    
    func cancel() {
        window(for: WindowTransitionContextToWindowKey)?.isHidden = true
        cancelled = true
    }
    
    func isCancelled() -> Bool {
        return cancelled
    }
}
