//
//  HumidDb.swift
//  PlantIot
//
//  Created by 우소연 on 03/12/2019.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class Humid: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var _humid: String?
    @objc var _index: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "AirHumid"
    }
    
    class func hashKeyAttribute() -> String {
        return "_humid"
    }
    class func rangeKeyAttribute() -> String {
        return "_index"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_humid" : "airHumid",
            "_index" : "index"
        ]
    }
}
