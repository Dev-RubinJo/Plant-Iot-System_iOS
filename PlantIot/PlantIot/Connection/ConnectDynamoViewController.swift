
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
    var humidarr = [[Int]]()//[index,humid]로 dynamodb읽어와서 저장하는 배열(삭제하기 위함)
    var soilarr = [[Int]]()//[index,soil]로 dynamodb읽어와서 저장하는 배열(삭제하기 위함)
    var temparr = [[Double]]()
    var cdsarr = [[Int]]()
    let name =  UserDefaults.standard.string(forKey: "name")//저장해둔 식물 이름 가져오기
    
    @IBOutlet weak var nameLbl: UILabel!{//맨 위에 hi! lia의 이름넣기
        didSet{
            nameLbl.text = "Hi, " + name! + "!"
        }
    }
    
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func pusheditBtn(_ sender: Any) {
         self.navigationController!.pushViewController(EditUserViewController(), animated: true)
    }
    
    @IBOutlet weak var houseLbl: UILabel!{//두 번째 이름넣기
        didSet{
            houseLbl.text = name! + "'s House :)"
        }
    }
    
    //on,off 버튼
    @IBOutlet weak var OnoffBtn: UIButton!
    //상태정보 view Box
    @IBOutlet weak var StatusBox: UIView!
    
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var airhumidityLbl: UILabel!
    @IBOutlet weak var soilhumidityLbl: UILabel!
    @IBOutlet weak var recommendLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //on,off버튼 잎 모양
        OnoffBtn.layer.cornerRadius = 0.5 * OnoffBtn.bounds.size.width
        //상태정보 테두리 둥글게
        StatusBox.layer.cornerRadius = 10
        //cognito unauth로 연결하기
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast2, identityPoolId: "ap-northeast-2:dbf2e92e-a032-4b12-b28c-e74e378af20f")
        
        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider: credentialsProvider)
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
    

    //dynamodb에 값 넣는 함수
                    func postToDB() {
                        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                        let newScore : Int = 222222221
                        //let objectMapper = AWSDynamoDBObjectMapper.default()
                        //let itemToCreate : Example = Example()
                        let va = 23
                        //let itemToCreate : Soil = Soil()
                        let itemToCreate : Example = Example()
                        //itemToCreate._soilhumid = String(va)
                        itemToCreate._userId = String(va)
                        itemToCreate._highScore = NSNumber(value: newScore)
                        print(itemToCreate)
                        dynamoDbObjectMapper.save(itemToCreate, completionHandler: {
                            (error: Error?) -> Void in
                            
                            if let error = error {
                                print("Amazon DynamoDB Save Error: \(error)")
                                return
                            }
                            print("An item was saved.")
                        })
                        delete()
                        // readDb()
                    }
    func delete(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let itemToDelete : Example = Example()
        let va = 21
        let newScore : Int = 222222221
        itemToDelete._userId = String(va)
        itemToDelete._highScore = NSNumber(value: newScore)
        dynamoDbObjectMapper.remove(itemToDelete).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else {
                print("Table Item deleted.")
            }
            return nil
        })
    }
    // 테이블 마다 있는게 좋을꺼같은데 어떻게할까? => 그럼 그렇게 합죠
    //dynamodb 읽어오기
    func readDb() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        //scanExpression.limit = 20//최대 스캔 갯수
        //humidscan 함수
        dynamoDbObjectMapper.scan(Humid.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let myhumid = index as! Humid
                    var humidindex = Int(myhumid._index!)//humid의 _index읽어오기
                    var humid = Int(myhumid._humid!)!//humid의 _humid읽어오기
                    self.humidarr.append([humidindex, humid])
                }
                self.humidarr.sort {$0[0] < $1[0]}
                print("humidarr")
                print(self.humidarr)
            }
            self.deleteAirHumidTableData()
            return nil
        })
        //soilscan 함수
        dynamoDbObjectMapper.scan(Soil.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let mysoil = index as! Soil
                    var soilindex = Int(mysoil._index!)
                    var soil = Int(mysoil._soilhumid!)!
                    self.soilarr.append([soilindex, soil])
                }
                self.soilarr.sort {$0[0] < $1[0]}
                print("soilarr")
                print(self.soilarr)
            }
            self.deleteSoilHumidTableData()
            return nil
        })
        //tempscan 함수
        dynamoDbObjectMapper.scan(Temp.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let mytemp = index as! Temp
                    var tempindex = Double(mytemp._index!)
                    var temp = Double(mytemp._temperature!)!
                    self.temparr.append([tempindex, temp])
                }
                self.temparr.sort {$0[0] < $1[0]}
                print("temparr")
                print(self.temparr)
            }
            self.deleteTemperatureTableData()
            return nil
        })
        //cds스캔 함수
        dynamoDbObjectMapper.scan(CDS.self, expression: scanExpression).continueWith(block: { (task:AWSTask!) -> AnyObject? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let mycds = index as! CDS
                    var cdsindex = Int(mycds._index!)
                    var cds = Int(mycds._cds!)!
                    self.cdsarr.append([cdsindex, cds])
                }
                self.cdsarr.sort {$0[0] < $1[0]}
                print("cdsarr")
                print(self.cdsarr)
            }
            // TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
            self.deleteCDSTableData()
            return nil
        })
    }
    // MARK: TODO:: 각 테이블 별로 remove 혹은 delete함수 생성하기
    // ex) deleteAirHumidTableData, deleteSoilHumidTableData, etc.
    //deleteAirHumidTableData
    func deleteAirHumidTableData(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let humidToDelete = Humid()//삭제할 humid객체 생성(row한개)
        if(humidarr.count > 1){//한개 보다 많이 남으면!
            for i in 0 ... humidarr.count - 2 {//humidarr에서 가장 최근 한 개 제외하고 삭제
                //객체에 지울 인덱스와 humid값 넣기
                humidToDelete?._humid = String(humidarr[i][1]);//객체에 지울 인덱스와 humid값 넣기
                humidToDelete?._index = NSNumber(value: humidarr[i][0]);
//                dynamoDbObjectMapper.remove(humidToDelete!).continueWith(block: { (task: AWSTask!) -> AnyObject? in
//                    if let error = task.error as? NSError {
//                        print("The request failed. Error: \(error)")
//                    } else {
//                        print("AirHumid Table Item deleted.")
//                    }
//                    return nil
//                })
                dynamoDbObjectMapper.remove(humidToDelete!, completionHandler: { (error: Error?) -> Void in
                    if let error = error {
                        print("The request failed. Error: \(error)")
                        return
                    }
                    print("AirHumid Table Item deleted.")
                })
            }
            DispatchQueue.main.async {
                self.airhumidityLbl.text = String(self.humidarr[0][1]) + "%"
            }
            
        }else{
            DispatchQueue.main.async {
                self.airhumidityLbl.text = String(self.humidarr[0][1]) + "%"
            }
        }
    }
    
    func deleteSoilHumidTableData(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let soilToDelete = Soil()
        if(soilarr.count > 1){
            for i in 0 ... soilarr.count - 2 {
                soilToDelete?._soilhumid = String(soilarr[i][1]);
                soilToDelete?._index = NSNumber(value: soilarr[i][0]);
                dynamoDbObjectMapper.remove(soilToDelete!).continueWith(block: { (task:AWSTask!) -> AnyObject? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else {
                        print("SoilHumid Table Item deleted.")
                    }
                    return nil
                })
            }
            DispatchQueue.main.async {
                self.soilhumidityLbl.text = String(self.soilarr[0][1]) + "%"
            }
        }else{
            DispatchQueue.main.async {
                self.soilhumidityLbl.text = String(self.soilarr[0][1]) + "%"
            }
        }
    }
    func deleteTemperatureTableData(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let tempToDelete : Temp = Temp()
        if(temparr.count > 1){
            for i in 0 ... temparr.count - 2 {
                var new = temparr[i][1] * 10
                var string = ""
                if new.truncatingRemainder(dividingBy: 10.0) == 0 {
                    string = String(Int(temparr[i][1]))
                }else{
                    new = temparr[i][1]
                    string = String(new)
                }
                tempToDelete._temperature = string;
                tempToDelete._index = NSNumber(value: temparr[i][0]);
                dynamoDbObjectMapper.remove(tempToDelete).continueWith(block: { (task:AWSTask!) -> AnyObject? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else {
                        print("Temperature Table Item  deleted.")
                    }
                    return nil
                })
            }
            DispatchQueue.main.async {
                self.tempLbl.text = String(self.temparr[0][1]) + "ºC"
            }
            
        }else{
            DispatchQueue.main.async {
                self.tempLbl.text = String(self.temparr[0][1]) + "ºC"
            }
        }
        
    }
    
    func deleteCDSTableData(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let cdsToDelete = CDS()
        if(cdsarr.count > 1){
            for i in 0 ... cdsarr.count - 2 {
                cdsToDelete?._cds = String(cdsarr[i][1]);
                cdsToDelete?._index = NSNumber(value: cdsarr[i][0]);
                dynamoDbObjectMapper.remove(cdsToDelete!).continueWith(block: { (task:AWSTask!) -> AnyObject? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else {
                        print("CDS Table Item deleted.")
                    }
                    return nil
                })
            }
        }
    }
    
}
