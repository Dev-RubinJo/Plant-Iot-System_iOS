//
//  BaseTabBarController.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/11/29.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit

class BaseTabBarController: CustomTabBarController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let connectionVC = ConnectionViewController()
        connectionVC.tabBarItem = UITabBarItem(title: "connection", image: nil, tag: 0)
        
        let publishVC = PublishViewController()
        publishVC.tabBarItem = UITabBarItem(title: "publish", image: nil, tag: 1)
        
        let subscribeVC = SubscribeViewController()
        subscribeVC.tabBarItem = UITabBarItem(title: "subscribe", image: nil, tag: 2)
        
        let configurationVC = ConfigurationViewController()
        configurationVC.tabBarItem = UITabBarItem(title: "configuration", image: nil, tag: 3)
        
        let tabBarList = [connectionVC, publishVC, subscribeVC, configurationVC]
        viewControllers = tabBarList
    }
    
    
}
