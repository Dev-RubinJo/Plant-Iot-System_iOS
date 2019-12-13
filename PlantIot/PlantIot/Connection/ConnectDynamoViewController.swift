
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

class ConnectDynamoViewController: BaseViewController {
    
    // MARK: TODO:: 변수들 뒤에 어떤 변수인지 주석 달아두기
    // 그러면 내가 변수 네이밍 리펙토링 할께
    var humidarr = [[Int]]()//[index,humid]로 dynamodb읽어와서 저장하는 배열(삭제하기 위함)
    var soilarr = [[Int]]()//[index,soil]로 dynamodb읽어와서 저장하는 배열(삭제하기 위함)
    var temparr = [[Double]]()
    var cdsarr = [[Int]]()
    var plantLedStatus: [PlantLed] = []
    let name =  UserDefaults.standard.string(forKey: "name")//저장해둔 식물 이름 가져오기
    
    @IBOutlet weak var nameLbl: UILabel!{//맨 위에 hi! lia의 이름넣기
        didSet{
            nameLbl.text = "Hi, " + name! + "!"
        }
    }
    
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func pusheditBtn(_ sender: Any) {
        let editVC = EditUserViewController()
        editVC.modalPresentationStyle = .fullScreen
        editVC.modalTransitionStyle = .flipHorizontal
        self.present(editVC, animated: true, completion: nil)
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
    @IBOutlet weak var temperatureStatusLabel: UILabel!
    @IBOutlet weak var airHumidStatusLabel: UILabel!
    @IBOutlet weak var recommendLbl: UILabel!
    @IBOutlet weak var cdsStatusLabel: UILabel! // 광량을 측정해서 주변이 얼마나 밝은지 어두운지 알 수 있도록 함
    
    
    let plantName = UserDefaults.standard.string(forKey: "name")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //on,off버튼 잎 모양
        OnoffBtn.layer.cornerRadius = 0.5 * OnoffBtn.bounds.size.width
        //상태정보 테두리 둥글게
        StatusBox.layer.cornerRadius = 10
        //cognito unauth로 연결하기
        
        self.getAWSClientID(completion: { (nil, error) in })
        self.connectToAWSIoT(clientId: self.clientId)
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast2, identityPoolId: "ap-northeast-2:dbf2e92e-a032-4b12-b28c-e74e378af20f")
        
        let configuration = AWSServiceConfiguration(region:.APNortheast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        //postToDB()
        //let db : Soil = Soil()
        readDb()
        self.OnoffBtn.tag = 0
        self.OnoffBtn.addTarget(self, action: #selector(self.pressPlantLedOnOFFButton(_:)), for: .touchUpInside)
        
        //readDb(_dbname: Humid)
        //readDb(_dbname: Temp)
        //        let stringMirror = Mirror(reflecting: Humid.self)
        //        print("type")
        //        print(stringMirror.subjectType)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        let plant = UserDefaults.standard.string(forKey: "name")!
        nameLbl.text = "Hi, " + plant + "!"
        houseLbl.text = plant + "'s House :)"
    }
    
    @objc func pressPlantLedOnOFFButton(_ sender: UIButton) {
        
        self.ledOnOffFunc(sender)
        var status: String = ""
        if sender.tag == 0 {
            status = "ON"
            self.OnoffBtn.setTitle("OFF", for: .normal)
        } else if sender.tag == 1 {
            status = "OFF"
            self.OnoffBtn.setTitle("ON", for: .normal)
        }
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        for index in self.plantLedStatus {
            if index._plantLed!.isEqual("ON") && sender.tag == 1 {
                dynamoDbObjectMapper.remove(index).continueWith(block: { (task:AWSTask!) -> Void in
                    if let error = task.error {
                        print("=================")
                        print(error)
                        print("=================")
                        return
                    }
                })
            } else if index._plantLed!.isEqual("OFF") && sender.tag == 0 {
                dynamoDbObjectMapper.remove(index).continueWith(block: { (task:AWSTask!) -> Void in
                    if let error = task.error {
                        print("=================")
                        print(error)
                        print("=================")
                        return
                    }
                })
            }
        }
        self.plantLedStatus[0]._plantLed = status
        dynamoDbObjectMapper.save(self.plantLedStatus[0], completionHandler: {
            (error: Error?) -> Void in
            if let error = error {
                print("=================")
                print(error)
                print("=================")
                return
            }
            self.readDBOnce()
        })
        // MARK: TODO:: justReadDB()같은 함수 만들어서 새로고침 하는거 넣으면 어떨까? --> 해결
        
        
//        self.readDb()
    }

    // 테이블 마다 있는게 좋을꺼같은데 어떻게할까? => 그럼 그렇게 합죠
    //dynamodb 읽어오기
    func readDb() {
        self.humidarr.removeAll()
        self.soilarr.removeAll()
        self.temparr.removeAll()
        self.cdsarr.removeAll()
        self.plantLedStatus.removeAll()
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
                DispatchQueue.main.async {
//                    self..text = String(self.temparr[0][1]) + "ºC"
                }
            }
            // TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
            self.deleteCDSTableData()
            return nil
        })
        // plantLed scan
        dynamoDbObjectMapper.scan(PlantLed.self, expression: scanExpression).continueWith(block: {(task: AWSTask!) -> Void in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let plantLed = index as! PlantLed
                    
//                    let ledStatus = String(plantLed._plantLed!)
                    self.plantLedStatus.append(plantLed)
                }
//                self.plantLedStatus
//                print("cdsarr")
//                print(self.cdsarr)
                
                if self.plantLedStatus[self.plantLedStatus.count - 1]._plantLed!.isEqual("ON") {
                    DispatchQueue.main.async {
                        self.cdsStatusLabel.text = "현재 불빛이 켜져있어요!"
                    }
                } else if self.plantLedStatus[self.plantLedStatus.count - 1]._plantLed!.isEqual("OFF") {
                    DispatchQueue.main.async {
                        self.cdsStatusLabel.text = "지금 불이 꺼져있네요"
                    }
                }
            }
            // TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
//            self.deleteCDSTableData()
        })
        // 1분 30초마다 값 업데이트
        self.updateUIByTime(90, completion: {
            self.readDb()
        })
    }
    // MARK: readDBOnce()
    func readDBOnce() {
        self.humidarr.removeAll()
        self.soilarr.removeAll()
        self.temparr.removeAll()
        self.cdsarr.removeAll()
        self.plantLedStatus.removeAll()
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
                DispatchQueue.main.async {
//                    self..text = String(self.temparr[0][1]) + "ºC"
                }
            }
            // TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
            self.deleteCDSTableData()
            return nil
        })
        // plantLed scan
        dynamoDbObjectMapper.scan(PlantLed.self, expression: scanExpression).continueWith(block: {(task: AWSTask!) -> Void in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let paginatedOutput = task.result {
                for index in paginatedOutput.items{
                    let plantLed = index as! PlantLed
//                    let ledStatus = String(plantLed._plantLed!)
                    self.plantLedStatus.append(plantLed)
                }
//                self.plantLedStatus
//                print("cdsarr")
//                print(self.cdsarr)
                print(self.plantLedStatus)
                if self.plantLedStatus[0]._plantLed!.isEqual("ON") {
                    DispatchQueue.main.async {
                        self.OnoffBtn.tag = 0
                    }
                } else if self.plantLedStatus[0]._plantLed!.isEqual("OFF") {
                    DispatchQueue.main.async {
                        self.OnoffBtn.tag = 1
                    }
                }
                if self.plantLedStatus[self.plantLedStatus.count - 1]._plantLed!.isEqual("ON") {
                    DispatchQueue.main.async {
                        self.cdsStatusLabel.text = "현재 불빛이 켜져있어요!"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.cdsStatusLabel.text = "지금 불이 꺼져있네요"
                    }
                }
            }
            // TODO:: 하단에 테이블 별로 지우는 함수 만든거 각 테이블에 맞게 넣어두기
//            self.deleteCDSTableData()
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
            
        }
        DispatchQueue.main.async {
            let airHumid = self.humidarr[self.humidarr.count - 1][1]
            self.airhumidityLbl.text = String(airHumid) + "%"
            
            if airHumid < 40 {
                self.airHumidStatusLabel.text = "\(self.plantName)는 너무 건조해요 ㅠㅁㅠ"
            } else if airHumid >= 40 && airHumid < 75 {
                self.airHumidStatusLabel.text = "\(self.plantName)는 아직 버틸 수 있어요!"
            } else if airHumid >= 75 {
                self.airHumidStatusLabel.text = "\(self.plantName)는 상쾌해요~!"
            }
            print("updated")
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
        }
        DispatchQueue.main.async {
            let soilHumid = self.soilarr[self.soilarr.count - 1][1]
            let soilHumidPercent = ((4095 - soilHumid) / 4095) * 100
            self.soilhumidityLbl.text = String(soilHumidPercent) + "%"
            
            if soilHumidPercent <= 50 {
                self.recommendLbl.text = "\(self.plantName)는 목이 말라요..."
            } else if soilHumidPercent > 50 && soilHumidPercent <= 80 {
                self.recommendLbl.text = "\(self.plantName)는 아직 괜찮아요~!"
            } else if soilHumidPercent > 80 {
               self.recommendLbl.text = "\(self.plantName)는 너무 좋아요!!"
           }
            print("updated")
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
            
        }
        DispatchQueue.main.async {
            let temp = self.temparr[self.temparr.count - 1][1]
            self.tempLbl.text = String(temp) + "ºC"
            let heaterState = UserDefaults.standard.bool(forKey: "heaterState")
            if temp < 15 {
                self.temperatureStatusLabel.text = "너무 추워서 \(self.plantName)가 온풍기 켰어요!"
                UserDefaults.standard.set(true, forKey: "heaterState")
            } else if temp > 15 && temp < 30 {
                self.temperatureStatusLabel.text = "지금 온도가 너무 좋아요!"
            } else if temp > 50 {
                self.temperatureStatusLabel.text = "지금 너무 뜨거운데 주변에 무슨 일이 일어난거같아요!"
            }
            
            if temp == 26.3 && heaterState {
                self.temperatureStatusLabel.text = "뜨거워질꺼같아서 온풍기를 껐어요!"
                UserDefaults.standard.set(false, forKey: "heaterState")
            }
            
            print("updated")
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
        if !self.plantLedStatus.isEmpty {
            if self.cdsarr[self.cdsarr.count - 1][1] < 1800 && self.plantLedStatus[self.plantLedStatus.count - 1]._plantLed!.isEqual("OFF") {
                DispatchQueue.main.async {
                    self.cdsStatusLabel.text = "지금은 해가 쨍쨍해요~"
                }
            } else if self.cdsarr[self.cdsarr.count - 1][1] > 1800 && self.cdsarr[self.cdsarr.count - 1][1] < 3000 && self.plantLedStatus[self.plantLedStatus.count - 1]._plantLed!.isEqual("OFF") {
                DispatchQueue.main.async {
                    self.cdsStatusLabel.text = "조금씩 어두워지고 있어요!"
                }
            } else if self.cdsarr[self.cdsarr.count - 1][1] > 3000 && self.plantLedStatus[self.plantLedStatus.count - 1]._plantLed!.isEqual("OFF") {
                DispatchQueue.main.async {
                    self.cdsStatusLabel.text = "주변이 너무 어둡네요.. \(self.plantName)에게 불을 켜주시겠어요?"
                }
            }
        }
    }
}
