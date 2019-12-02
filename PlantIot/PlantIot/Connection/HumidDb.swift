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
      
      class func dynamoDBTableName() -> String {
          return "AirHumid"
      }

      class func hashKeyAttribute() -> String {
          return "_humid"
      }


      override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
          return [
              "_humid" : "Humid",
          ]
      }
}
