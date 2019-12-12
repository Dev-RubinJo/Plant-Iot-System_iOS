//
//  SplashViewController.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/12/12.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit

class SplashViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if UserDefaults.standard.string(forKey: "name") == nil{
            let mainVC = CreateUserViewController()
            UIApplication.shared.keyWindow?.rootViewController = mainVC
        } else {
            let mainVC = ConnectDynamoViewController()
            UIApplication.shared.keyWindow?.rootViewController = mainVC
        }
        
//        UIView.animate(withDuration: 1.0, animations: {
//            // animation
////            self.titleLabel.
//        }, completion: { finished in
//            // todo
//            let mainVC = CreateUserViewController()
//            UIApplication.shared.keyWindow?.rootViewController = mainVC
//        })
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

}
