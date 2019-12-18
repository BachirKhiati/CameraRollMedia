//
//  UIAlertController.swift
//  RNCameraRollMedia
//
//  Created by Bachir Khiati on 18/12/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//


import UIKit

extension UIAlertController {
    
    func show() {
        DispatchQueue.main.async{
            self.present(animated: true, completion: nil)
        }
        
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else
            if let tabVC = controller as? UITabBarController,
                let selectedVC = tabVC.selectedViewController {
                presentFromController(controller: selectedVC, animated: animated, completion: completion)
            } else {
                controller.present(self, animated: animated, completion: completion);
        }
    }
}
