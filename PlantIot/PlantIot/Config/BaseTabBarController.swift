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
        
        let tabBarList = [connectionVC]
        viewControllers = tabBarList
    }
    
    
}
