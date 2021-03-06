//
//  PresentAnimationController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public final class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    public override init() {
        super.init()
    }
    
    // MARK: - Elements
    
    public weak var transitionController: TransitionController!
    
    public var transitionDuration: TimeInterval = 0.5
    
    public var usingSpringWithDamping: CGFloat = 0.7
    
    public var initialSpringVelocity: CGFloat = 0.0
    
    public var animationOptions: UIView.AnimationOptions = [.curveEaseInOut, .allowUserInteraction]
    
    fileprivate(set) var initialTransitionView: UIView?
    
    fileprivate(set) var destinationTransitionView: UIView?

    var initialSnapshotImage: UIImage?
    
    var destinationSnapshotImage: UIImage?
    
    // MARK: - Prepare
    
    func prepare() {
        
        guard let presentingViewController = transitionController.presentingViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller")
            }
            return
        }
        guard let presentedViewController = transitionController.presentedViewController else {
            if transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presented view controller")
            }
            return
        }

        presentingViewController.prepareInitialView(transitionController.context, isPresenting: true)
        let initialView: UIView = presentingViewController.initialView(transitionController.context, isPresenting: true)
        initialTransitionView = initialView.snapshotView(afterScreenUpdates: false)

        presentedViewController.prepareDestinationView(transitionController.context, isPresenting: true)
        let destinationView: UIView = presentedViewController.destinationView(transitionController.context, isPresenting: true)
        destinationTransitionView = destinationView.snapshotView(afterScreenUpdates: true)
    }
    
    // MARK: - Transition

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get ViewControllers and Container View

        let rawFrom = transitionContext.viewController(forKey: .from)
        let rawTo = transitionContext.viewController(forKey: .to)

        guard let fromViewController = rawFrom?.unpackedViewController as? UIViewController & View2ViewTransitionPresenting else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presenting view controller (\(transitionContext.viewController(forKey: .from) as Any)))")
            }
            return
        }
        guard let toViewController = rawTo?.unpackedViewController as? UIViewController & View2ViewTransitionPresented else {
            if self.transitionController.debuging {
                debugPrint("View2ViewTransition << No valid presented view controller (\(transitionContext.viewController(forKey: .to) as Any))")
            }
            return
        }
        
        if self.transitionController.debuging {
            debugPrint("View2ViewTransition << Will Present")
            debugPrint(" Presenting view controller: \(fromViewController)")
            debugPrint(" Presented view controller: \(toViewController)")
        }
        
        let containerView = transitionContext.containerView

        fromViewController.prepareInitialView(self.transitionController.context, isPresenting: true)
        let initialView: UIView = fromViewController.initialView(self.transitionController.context, isPresenting: true)
        let initialFrame: CGRect = fromViewController.initialFrame(self.transitionController.context, isPresenting: true)
        
        toViewController.prepareDestinationView(self.transitionController.context, isPresenting: true)
        let destinationView: UIView = toViewController.destinationView(self.transitionController.context, isPresenting: true)
        let destinationFrame: CGRect = toViewController.destinationFrame(self.transitionController.context, isPresenting: true)
        
        // Hide Transisioning Views
        initialView.isHidden = true
        destinationView.isHidden = true
        
        // Add ToViewController's View
        let toViewControllerView: UIView = toViewController.view
        toViewControllerView.alpha = CGFloat.leastNormalMagnitude
        containerView.addSubview(toViewControllerView)
        
        // Add Snapshot
        initialTransitionView?.frame = initialFrame
        if let view = initialTransitionView {
            containerView.addSubview(view)
        }
        
        destinationTransitionView?.frame = initialFrame
        if let view = destinationTransitionView {
            containerView.addSubview(view)
        }
        destinationTransitionView?.alpha = 0.0
        
        // Animation
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: self.usingSpringWithDamping, initialSpringVelocity: self.initialSpringVelocity, options: self.animationOptions, animations: {
            
            self.initialTransitionView?.frame = destinationFrame
            self.initialTransitionView?.alpha = 0.0
            self.destinationTransitionView?.frame = destinationFrame
            self.destinationTransitionView?.alpha = 1.0
            toViewControllerView.alpha = 1.0
            
        }, completion: { _ in
                
            self.initialTransitionView?.removeFromSuperview()
            self.destinationTransitionView?.removeFromSuperview()
                
            initialView.isHidden = false
            destinationView.isHidden = false
                
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
