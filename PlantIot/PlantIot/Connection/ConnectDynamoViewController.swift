//
//  ConnectDynamoViewController.swift
//  PlantIot
//
//  Created by 우소연 on 02/12/2019.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit
import AWSDynamoDB
import AWSMobileClient
import AWSCore
import AWSAuthCore

class ConnectDynamoViewController: UIViewController {

    
    var arr : [String] = []
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast2, identityPoolId: "ap-northeast-2:dbf2e92e-a032-4b12-b28c-e74e378af20f")

        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        postToDB()
    }
    override func viewWillAppear(_ animated: Bool) {
        //postToDB()
        //createBooks()
    }
    
    let deviceId : String = (UIDevice.current.identifierForVendor?.uuidString)!
    func postToDB() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let newScore : Int = 222222222
        // Create data object using data models you downloaded from Mobile Hub
        //let objectMapper = AWSDynamoDBObjectMapper.default()
        let itemToCreate : Example = Example()

        itemToCreate._userId = deviceId
        itemToCreate._highScore = NSNumber(value: newScore)
        print(itemToCreate._highScore)
        print(itemToCreate)
        print("여기여기 - \(itemToCreate._highScore!)")

        dynamoDbObjectMapper.save(itemToCreate, completionHandler: {
            (error: Error?) -> Void in

            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        readBooks()
    }
    
    func readBooks() {
      let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()

        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 20
        
        
        dynamoDbObjectMapper.scan(Humid.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for humid in paginatedOutput.items{
                   
                    let myhumid = humid as! Humid
                   
                    self.arr.append(myhumid._humid!)
                    // Do something with book.
                }
                print(self.arr)
            }
            self.removeDb()
            return nil
        })
    }
    
    func removeDb(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()

        let humidToDelete = Humid()
         humidToDelete?._humid = arr[0];

        dynamoDbObjectMapper.remove(humidToDelete!).continueWith(block: { (task:AWSTask!) -> AnyObject? in
             if let error = task.error as? NSError {
                 print("The request failed. Error: \(error)")
             } else {
                 print("Item deleted.")
             }
            return nil
         })
    }

}
