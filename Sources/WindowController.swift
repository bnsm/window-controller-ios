//
//  WindowController.swift
//  WindowController
//
//  Created by Martin Banas on 12/03/17.
//  Copyright © 2017 WindowController Contributors. All rights reserved.
//

import UIKit

open class WindowController {
    
    open var topWindow: UIWindow? {
        return windows.last
    }
    
    public var presenting: Bool {
        return windows.count > 1 || (windows.count > 0 && transitioning)
    }
    
    public private(set) var windows: [UIWindow]
    
    private var transitions = [WindowContextTransitioning]()
    
    private var transitioning = false
    
    public init(root window: UIWindow) {
        windows = [window]
    }
    
    // MARK: Public methods
    
    open func present(window: UIWindow, animated: Bool, animator: WindowAnimatedTransitioning?, completion: ((_ didComplete: Bool) -> Void)?) {
        
        if !startTransition(completion: completion) {
            return
        }

        transit(to: window, animated: animated, animator: animator) { [weak self] (didComplete) -> Void in
            if didComplete {
                self?.windows.append(window)
            }
            
            self?.stopTransition(didComplete: didComplete, completion: completion)
        }
    }
    
    open func dismiss(window: UIWindow, animated: Bool, animator: WindowAnimatedTransitioning?, completion: ((_ didComplete: Bool) -> Void)?) {
        
        // Makes sure the app is not trying to dismiss the root window
        guard window != windows.first else {
            print("Warning: Attempt to dismiss root window, using the WindowController")
            completion?(false)
            return
        }
        
        // Makes sure the window is actually presented
        guard let windowIndex = windows.index(of: window) else {
            print("Warning: Attempt to dismiss \(window) which is not presented")
            completion?(false)
            return
        }
        
        if !startTransition(completion: completion) {
            return
        }
        
        let previousWindow = windows[windowIndex - 1]

        transit(to: previousWindow, animated: animated, animator: animator) { [weak self] (didComplete) -> Void in
            if didComplete {
                self?.windows.remove(at: windowIndex)
            }
            
            self?.stopTransition(didComplete: didComplete, completion: completion)
        }
    }
    
    open func dismiss(windows: [UIWindow], animated: Bool, animator: WindowAnimatedTransitioning?, completion: ((_ didComplete: Bool) -> Void)?) {
        
        if !startTransition(completion: completion) {
            return
        }
        
        for window in windows {
            if window != self.windows.first && window != topWindow {
                window.isHidden = true
            }
        }
        
        var newWindows = [UIWindow]()
        
        for w in self.windows {
            if !windows.contains(w) {
                newWindows.append(w)
            }
        }
        
        if let window = topWindow, windows.contains(window), let lastWindow = newWindows.last {
            lastWindow.windowLevel = window.windowLevel + 1
            
            transit(to: lastWindow, animated: animated, animator: animator, completion: { [weak self] (didComplete) -> Void in
                if didComplete {
                    self?.windows = newWindows
                }

                self?.stopTransition(didComplete: didComplete, completion: completion)
            })
            
        } else {
            self.windows = newWindows
            stopTransition(didComplete: true, completion: completion)
        }
    }
    
    // MARK: Private methods
    
    private func startTransition(completion: ((_ didComplete: Bool) -> Void)?) -> Bool {
        if transitioning {
            print("Warning: Attempt to make transition while a presentation is in progress, using the WindowController")
            completion?(false)
            return false
            
        } else {
            transitioning = true
            return true
        }
    }
    
    private func stopTransition(didComplete: Bool, completion: ((_ didComplete: Bool) -> Void)?) {
        transitioning = false
        completion?(didComplete)
    }
    
    private func transit(to window: UIWindow, animated: Bool, animator: WindowAnimatedTransitioning?, completion: ((_ didComplete: Bool) -> Void)?) {

        // Makes sure controller is not trying to present the top window again
        if window == topWindow {
            print("Warning: Attempt to transit to the top window \(window), using the WindowController")
            completion?(false)
            return
        }
        
        // If there is no window presented yet
        guard let fromWindow = topWindow else {
            
            // Presents the new window without animation
            window.makeKeyAndVisible()
            completion?(true)
            return
        }
        
        // Transitioning from an old window to a new window
        window.rootViewController?.beginAppearanceTransition(true, animated: animated)
        window.makeKey()
        
        let transitionAnimator = animator ?? BaseWindowAnimatedTransition(duration: 0.25)
        let transitionContext = BaseWindowContextTransition(fromWindow: fromWindow, toWindow: window, animated: animated)
        
        transitionContext.completion = { (didComplete) in
            if didComplete {
                window.isUserInteractionEnabled = true
                window.rootViewController?.endAppearanceTransition()
                
                fromWindow.isUserInteractionEnabled = false
                fromWindow.isHidden = true
                
            } else {
                fromWindow.isUserInteractionEnabled = true
                fromWindow.makeKeyAndVisible()
                
                window.rootViewController?.beginAppearanceTransition(false, animated: animated)
                window.isUserInteractionEnabled = false
                window.isHidden = true
                window.rootViewController?.endAppearanceTransition()
            }
            
            self.transitions = self.transitions.filter { $0 !== transitionContext }
            self.topWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            
            completion?(didComplete)
        }
        
        window.isHidden = false
        window.isUserInteractionEnabled = false
        fromWindow.isUserInteractionEnabled = false
        
        transitions.append(transitionContext)
        transitionAnimator.animateTransition(transitionContext: transitionContext)
    }
}
