//
//  MainTabBarController.swift
//  Pitaya
//
//  Created by Eric Lin on 2022/10/14.
//  Copyright © 2022 Eric Lin. All rights reserved.
//

import UIKit

/// TabBar Tag
///  - frontPage: 首頁
///  - mapSearch: 地圖搜尋
///  - collections: 收藏
///  - About: 設定
enum AppTag: Int {
    case frontPage = 0
    case mapSearch
    case collections
    case About
}

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TabBarStyle設定
        if #available(iOS 15.0, *) {
            let tabbarAppearance = UITabBarAppearance()
            tabbarAppearance.backgroundColor = UIColor.sageGreen

            tabbarAppearance.stackedLayoutAppearance.normal.iconColor = .white //未選中
            tabbarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.boldSystemFont(ofSize: 14) ]

            tabbarAppearance.stackedLayoutAppearance.selected.iconColor = .orangeRed //選中
            tabbarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.orangeRed,
                .font: UIFont.boldSystemFont(ofSize: 14) ]

            UITabBar.appearance().scrollEdgeAppearance = tabbarAppearance
            UITabBar.appearance().standardAppearance = tabbarAppearance

        } else {
            UITabBar.appearance().tintColor = UIColor.orangeRed
            UITabBar.appearance().unselectedItemTintColor = UIColor.white //未選中
            UITabBar.appearance().barTintColor = UIColor.sageGreen
            UITabBar.appearance().backgroundColor = UIColor.sageGreen
        }
        
        self.setUpChildViewControllers()
    }
    
    // 初始化 TabBar
    private func setUpChildViewControllers() {
        // 首頁
        let frontPageViewModel = FrontPageViewModel()
        let firstViewController = FrontPageViewController(viewModel: frontPageViewModel)
        self.addChildViewController(childController: firstViewController,
                                    image: "briefcase.fill",
                                    tag: .frontPage)
        
        // 地圖搜尋
        let mapViewModel = MapSearchViewModel()
        let mapViewController = MapSearchViewController(viewModel: mapViewModel)
        self.addChildViewController(childController: mapViewController,
                                    image: "map.fill",
                                    tag: .mapSearch)
        
        // 3. 收藏頁
        let vm = CollectionsViewModel()
        let secondViewController = CollectionsViewController(viewModel: vm)
        self.addChildViewController(childController: secondViewController,
                                    image: "list.clipboard",
                                    tag: .collections)
        
        // 4. 關於頁
        let viewModel = AboutViewModel()
        let thirdViewController = AboutViewController(viewModel: viewModel)
        self.addChildViewController(childController: thirdViewController,
                                    image: "gearshape.2.fill",
                                    tag: .About)
    }
    
    // 初始化 Navigation
    private func addChildViewController(childController: UIViewController,
                                        image: String,
                                        tag: AppTag) {
        
        childController.tabBarItem.image = UIImage.init(systemName: image)
        childController.tabBarItem.tag = tag.rawValue
    
        let navigationController = UINavigationController(rootViewController: childController)
        
        self.addChild(navigationController)
    }
}


