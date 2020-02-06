//
//  TransitionController.swift
//  CustomTransition
//
//  Created by naru on 2016/08/26.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit

public enum TransitionControllerType {
    case presenting
    case pushing
}

public class TransitionControllerContext {
    public var initialIndexPath: IndexPath?
    public var destinationIndexPath: IndexPath?
}

public final class TransitionController: NSObject {
    
    public var debuging: Bool = false
    
    public let context = TransitionControllerContext()
    
    private(set) var type: TransitionControllerType = .presenting
    
    public lazy var presentAnimationController: PresentAnimationController = {
        let controller: PresentAnimationController = PresentAnimationController()
        controller.transitionController = self
        return controller
    }()
    
    public lazy var dismissAnimationController: DismissAnimationController = {
        let controller: DismissAnimationController = DismissAnimationController()
        controller.transitionController = self
        return controller
    }()
    
    public lazy var dismissInteractiveTransition: DismissInteractiveTransition = {
        let interactiveTransition: DismissInteractiveTransition = DismissInteractiveTransition()
        interactiveTransition.transitionController = self
        interactiveTransition.animationController = self.dismissAnimationController
        return interactiveTransition
    }()
    
    fileprivate(set) weak var presentingViewController: (UIViewController & View2ViewTransitionPresenting)?
    
    fileprivate(set) var presentedViewController: (UIViewController & View2ViewTransitionPresented)?

    /// Type Safe Present for Swift
    public func present(viewController presentedViewController: UIViewController & View2ViewTransitionPresented,
                        on presentingViewController: UIViewController & View2ViewTransitionPresenting,
                        attached: UIViewController, completion: (() -> Void)?) {
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        pan.delegate = self

        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.type = .presenting
        
        // Present
        presentingViewController.present(presentedViewController, animated: true, completion: completion)
    }
    
    
    /// Type Safe Push for Swift
    public func push(viewController presentedViewController: UIViewController & View2ViewTransitionPresented,
                     on presentingViewController: UIViewController & View2ViewTransitionPresenting,
                     attached: UIViewController) {
        
        guard let navigationController = presentingViewController.navigationController else {
            if self.debuging {
                debugPrint("View2ViewTransition << Cannot Find Navigation Controller for Presenting View Controller")
            }
            return
        }
        
        let pan = UIPanGestureRecognizer(target: dismissInteractiveTransition, action: #selector(dismissInteractiveTransition.handlePanGesture(_:)))
        attached.view.addGestureRecognizer(pan)
        pan.delegate = self
        
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.type = .pushing
        
        // Push
        navigationController.pushViewController(presentedViewController, animated: true)
    }
}

extension TransitionController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let transate: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        return Double(abs(transate.y)/abs(transate.x)) > .pi / 4.0
    }
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentAnimationController.prepare()
        return presentAnimationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissAnimationController.prepare()
        return dismissAnimationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissInteractiveTransition.interactionInProgress ? dismissInteractiveTransition : nil
    }
}

extension TransitionController: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            presentAnimationController.prepare()
            return presentAnimationController
        case .pop:
            dismissAnimationController.prepare()
            return dismissAnimationController
        default:
            return nil
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController === self.dismissAnimationController && self.dismissInteractiveTransition.interactionInProgress {
            return self.dismissInteractiveTransition
        }
        return nil
    }
}
