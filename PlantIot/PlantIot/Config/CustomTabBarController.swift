//
//  CustomTabBarController.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/11/29.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    @objc var mqttStatus: String = "Disconnected"
    @objc var topic: String = "slider"
}
