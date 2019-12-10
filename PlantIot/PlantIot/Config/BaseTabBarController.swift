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
        let connectionDBVC = ConnectDynamoViewController()
        let createuserVC = CreateUserViewController()
        connectionVC.tabBarItem = UITabBarItem(title: "connection", image: nil, tag: 0)
        connectionDBVC.tabBarItem = UITabBarItem(title: "db", image: nil, tag: 1)
        createuserVC.tabBarItem = UITabBarItem(title: "start", image: nil, tag: 1)
        let tabBarList = [connectionVC, createuserVC]
        viewControllers = tabBarList
    }
    
    
}
