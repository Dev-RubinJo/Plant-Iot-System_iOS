//
//  SubscribeViewController.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/11/29.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit
import AWSIoT

class SubscribeViewController: UIViewController {

    @IBOutlet weak var subscribeSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        subscribeSlider.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        let tabBarViewController = tabBarController as! CustomTabBarController

        iotDataManager.subscribe(toTopic: tabBarViewController.topic, qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: {
            (payload) ->Void in
            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!

            print("received: \(stringValue)")
            DispatchQueue.main.async {
                self.subscribeSlider.value = stringValue.floatValue
            }
        } )
    }

    override func viewWillDisappear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        let tabBarViewController = tabBarController as! CustomTabBarController
        iotDataManager.unsubscribeTopic(tabBarViewController.topic)
    }
}

