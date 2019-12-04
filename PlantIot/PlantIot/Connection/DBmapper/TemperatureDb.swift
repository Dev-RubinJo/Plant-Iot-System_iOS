//
//  TemperatureDb.swift
//  PlantIot
//
//  Created by 우소연 on 04/12/2019.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class Temp: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var _temp: String?
    @objc var _index: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "Temperature"
    }
    
    class func hashKeyAttribute() -> String {
        return "_temp"
    }
    
    class func rangeKeyAttribute() -> String {
        return "_index"
    }
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_temp" : "temperature",
            "_index" : "index"
        ]
    }
}
