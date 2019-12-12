//
//  PlantLedDB.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/12/12.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import Foundation
import AWSDynamoDB

class PlantLed: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var _plantLed: String?
    
    class func dynamoDBTableName() -> String {
        return "PlantLed"
    }
    
    class func hashKeyAttribute() -> String {
        return "_plantLed"
    }

    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_plantLed" : "plantLed"
        ]
    }
}
