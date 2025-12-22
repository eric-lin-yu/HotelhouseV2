//
//  UINavigationController+Extension.swift
//  寶島旅社
//
//  Created by wistronits on 2025/12/22.
//  Copyright © 2025 Eric Lin. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    /// 設定導航欄為透明（適用於全螢幕地圖或大圖背景）
    func setupTransparentAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.compactAppearance = appearance
    }
    
    /// 恢復專案預設的導航欄樣式（SageGreen 背景）
    func setupDefaultAppearance() {
        let appearance = UINavigationBarAppearance()
        // 這裡套用你在 AppDelegate 定義的預設風格
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .sageGreen
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.orangeRed,
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.compactAppearance = appearance
    }
}
