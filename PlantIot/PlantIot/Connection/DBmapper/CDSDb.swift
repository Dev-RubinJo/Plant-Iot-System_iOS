//
//  CDSDb.swift
//  PlantIot
//
//  Created by 우소연 on 10/12/2019.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import Foundation
import UIKit
import AWSDynamoDB

class CDS: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var _cds: String?
    @objc var _index: NSNumber?
    
    class func dynamoDBTableName() -> String {
        return "CDS"
    }
    
    class func hashKeyAttribute() -> String {
        return "_cds"
    }
    
    class func rangeKeyAttribute() -> String {
        return "_index"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_cds" : "cds",
            "_index" : "index"
        ]
    }
}
