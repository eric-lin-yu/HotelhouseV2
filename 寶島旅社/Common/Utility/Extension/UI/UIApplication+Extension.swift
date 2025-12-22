//
//  UIApplication+Extension.swift
//  MessageDemo
//
//  Created by Cheryl Chen on 2019/12/3.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static func rootViewContains(subview: UIView) -> Bool {
        if var topController = UIApplication.shared.topWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController.view.subviews.contains(subview)
        }
        return false
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.topWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static func addViewOnTopWindow(view: UIView) {
        UIApplication.shared.topLevelWindow?.addSubview(view)
    }
    
//    var availableKeyWindow: UIWindow? {
//       if #available(iOS 14, *) {
//            // when not use keyWindow add subviews that had textfield will change firstResponder, and then could not assign firstResponder to ChatRooms VC
////            return UIApplication.shared.windows[0]
//           return UIApplication.shared.windows[0]
//           
//        } else {
//            return UIApplication.shared.keyWindow
//        }
//    }
    
    var topLevelWindow: UIWindow? {
        return UIApplication.shared.windows
            .filter({ !$0.isHidden })
            .sorted(by: { $0.windowLevel > $1.windowLevel })
            .first
//        if let windowScene = UIApplication.shared.connectedScenes
//            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//            return windowScene.windows
//                .filter({ !$0.isHidden })
//                .sorted(by: { $0.windowLevel > $1.windowLevel })
//                .first
//        }
//        return nil
    }
    
    var topWindow: UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            return windowScene.windows
                .sorted(by: { $0.windowLevel > $1.windowLevel })
                .first
        }
        return nil
    }
    
    /// Checks if view hierarchy of application contains `UIRemoteKeyboardWindow` if it does, keyboard is presented
//    var isKeyboardPresented: Bool {
//        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"),
//            self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
//            return true
//        } else {
//            return false
//        }
//    }
    
    @discardableResult
    func availableOpenURL(url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:], completionHandler completion: ((Bool) -> Void)? = nil) -> Bool? {
        if #available(iOS 10, *) {
            self.open(url, options: options, completionHandler: completion)
            return nil
        } else {
            return self.openURL(url)
        }
    }
}
