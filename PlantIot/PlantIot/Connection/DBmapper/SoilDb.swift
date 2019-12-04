//
//  SoilDb.swift
//  PlantIot
//
//  Created by 우소연 on 04/12/2019.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class Soil: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var _soilhumid: String?
    @objc var _index: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "SoilHumid"
    }
    
    class func hashKeyAttribute() -> String {
        return "_soilhumid"
    }
    
    class func rangeKeyAttribute() -> String {
        return "_index"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_soilhumid" : "soilHumid",
            "_index" : "index"
        ]
    }
}
