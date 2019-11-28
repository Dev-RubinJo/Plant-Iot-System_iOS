//
//  PublishViewController.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/11/29.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit
import AWSIoT

class PublishViewController: UIViewController {

    @IBOutlet weak var publishSlider: UISlider!

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("Publish slider value: " + "\(sender.value)")

        let iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        let tabBarViewController = tabBarController as! CustomTabBarController

        iotDataManager.publishString("\(sender.value)", onTopic:tabBarViewController.topic, qoS:.messageDeliveryAttemptedAtMostOnce)
    }
}
