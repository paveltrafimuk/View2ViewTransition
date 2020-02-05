//
//  UIViewController+Extension.swift
//  Collection.Direct
//
//  Created by troff on 11/12/19.
//  Copyright © 2019 CD. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // unpack vc from navigationVC, usefull for animators - get really finalVC inside navigationController
    var unpackedViewController: UIViewController {
        let unpackedVC: UIViewController?
        if let navVC = self as? UINavigationController {
            unpackedVC = navVC.viewControllers.first
        }
        else {
            unpackedVC = nil
        }
        return unpackedVC ?? self
    }
}

