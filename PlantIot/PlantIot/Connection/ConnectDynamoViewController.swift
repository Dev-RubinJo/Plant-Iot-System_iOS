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
    
    // MARK: TODO:: 변수들 뒤에 어떤 변수인지 주석 달아두기
    // 그러면 내가 변수 네이밍 리펙토링 할께
    var humidarr : [Humid] = []
    var arr = [[Int]]()
    
    var soilarr = [[Int]]()
    var temparr : [String] = []
    
    //on,off 버튼
    @IBOutlet weak var OnoffBtn: UIButton!
    //상태정보 view Box
    @IBOutlet weak var StatusBox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //on,off버튼 잎 모양
        OnoffBtn.layer.cornerRadius = 0.5 * OnoffBtn.bounds.size.width
        //상태정보 테두리 둥글게
        StatusBox.layer.cornerRadius = 10
            
    
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast2, identityPoolId: "ap-northeast-2:dbf2e92e-a032-4b12-b28c-e74e378af20f")
        
        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        //postToDB()
        //let db : Soil = Soil()
        readDb()
        
        //readDb(_dbname: Humid)
        //readDb(_dbname: Temp)
        //        let stringMirror = Mirror(reflecting: Humid.self)
        //        print("type")
        //        print(stringMirror.subjectType)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //postToDB()
        //createBooks()
    }
    
    let deviceId : String = (UIDevice.current.identifierForVendor?.uuidString)!
    
                //    func postToDB() {
                //        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                //        let newScore : Int = 222222222
                //        //let objectMapper = AWSDynamoDBObjectMapper.default()
                //        //let itemToCreate : Example = Example()
                //        let va = 20
                //        //let itemToCreate : Soil = Soil()
                //        let itemToCreate : Temp = Temp()
                //        //itemToCreate._soilhumid = String(va)
                //        itemToCreate._temp = "22"
                //        itemToCreate._index = NSNumber(value: newScore)
                //        print(itemToCreate)
                //        dynamoDbObjectMapper.save(itemToCreate, completionHandler: {
                //            (error: Error?) -> Void in
                //            
                //            if let error = error {
                //                print("Amazon DynamoDB Save Error: \(error)")
                //                return
                //            }
                //            print("An item was saved.")
                //        })
                //        // readDb()
                //    }
    // 테이블 마다 있는게 좋을꺼같은데 어떻게할까?
    func readDb() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.limit = 20
        dynamoDbObjectMapper.scan(Humid.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let myhumid = index as! Humid
                    var new = Int(myhumid._index!)
                    var new2 = Int(myhumid._humid!)!
                    self.arr.append([new, new2])
                }
                self.arr.sort {$0[0] < $1[0]}
                
                print(self.arr)
            }
            // MARK: TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
            self.removeDb()
            return nil
        })
        dynamoDbObjectMapper.scan(Soil.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let mysoil = index as! Soil
                    var new = Int(mysoil._index!)
                    var new2 = Int(mysoil._soilhumid!)!
                    self.soilarr.append([new, new2])
                }
                self.soilarr.sort {$0[0] < $1[0]}
                
                print(self.soilarr)
            }
            // TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
            self.removeDb()
            return nil
        })
    }
    // MARK: TODO:: 각 테이블 별로 remove 혹은 delete함수 생성하기
    // ex) deleteAirHumidTableData, deleteSoilHumidTableData, etc.
    func removeDb(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let humidToDelete = Humid()
        let soilToDelete = Soil()
        for i in 0 ... soilarr.count - 2 {
            soilToDelete?._soilhumid = String(soilarr[i][1]);
            soilToDelete?._index = NSNumber(value: soilarr[i][0]);
            dynamoDbObjectMapper.remove(soilToDelete!).continueWith(block: { (task:AWSTask!) -> AnyObject? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else {
                    print("Item deleted.")
                }
                return nil
            })
        }
    }
    
}
