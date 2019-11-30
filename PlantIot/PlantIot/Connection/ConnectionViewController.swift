//
//  ConnectionViewController.swift
//  PlantIot
//
//  Created by YoobinJo on 2019/11/29.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit
import AWSIoT
import AWSMobileClient

class ConnectionViewController: UIViewController {
    
    @IBOutlet weak var logTextView: UITextView!

    @objc var connected = false;
    @objc var publishViewController : UIViewController!;
    @objc var subscribeViewController : UIViewController!;
    @objc var configurationViewController : UIViewController!;

    @objc var iotDataManager: AWSIoTDataManager!;
    @objc var iotManager: AWSIoTManager!;
    @objc var iot: AWSIoT!
    
    @objc var clientId: String = ""
//    var payload: Dictionary = [:]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create AWS credentials and configuration
        let credentials = AWSCognitoCredentialsProvider(regionType: .APNortheast2, identityPoolId: "ap-northeast-2:dbf2e92e-a032-4b12-b28c-e74e378af20f")
        let configuration = AWSServiceConfiguration(region: .APNortheast2, credentialsProvider: credentials)
        
        // Initialising AWS IoT And IoT DataManager
        AWSIoT.register(with: configuration!, forKey: "kAWSIoT")  // Same configuration var as above
        let iotEndPoint = AWSEndpoint(urlString: "wss://a2iilqapybb349-ats.iot.ap-northeast-2.amazonaws.com/mqtt") // Access from AWS IoT Core --> Settings
        let iotDataConfiguration = AWSServiceConfiguration(region: .APNortheast2,     // Use AWS typedef .Region
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentials)  // credentials is the same var as created above
            
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: "kDataManager")

        // Access the AWSDataManager instance as follows:
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        
        self.getAWSClientID(completion: { (nil, error) in })
        
        let tabBarViewController = tabBarController as! CustomTabBarController
        publishViewController = tabBarViewController.viewControllers![1]
        subscribeViewController = tabBarViewController.viewControllers![2]
        configurationViewController = tabBarViewController.viewControllers![3]

        tabBarViewController.viewControllers = [ self, configurationViewController ]
        self.logTextView.text = self.clientId
        self.connectToAWSIoT(clientId: self.clientId)
        
        
        logTextView.resignFirstResponder()
        self.registerSubscriptions()
//        print(self.payload)
        
//        while true {
//            self.delayWithSecondsOnUI(1.0, completion: {
//                print(1)
//                self.registerSubscriptions()
//            })
//        }
        

//        // Initialize AWSMobileClient for authorization
//        AWSMobileClient.sharedInstance().initialize { (userState, error) in
//            guard error == nil else {
//                print("Failed to initialize AWSMobileClient. Error: \(error!.localizedDescription)")
//                return
//            }
//            print("AWSMobileClient initialized.")
//        }
//
//        // Init IOT
//        let iotEndPoint = AWSEndpoint(urlString: IOT_ENDPOINT)
//
//        // Configuration for AWSIoT control plane APIs
//        let iotConfiguration = AWSServiceConfiguration(region: .APNortheast2, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
//
//        // Configuration for AWSIoT data plane APIs
//        let iotDataConfiguration = AWSServiceConfiguration(region: .APNortheast2,
//                                                           endpoint: iotEndPoint,
//                                                           credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
//        AWSServiceManager.default().defaultServiceConfiguration = iotConfiguration
//
//        iotManager = AWSIoTManager.default()
//        iot = AWSIoT.default()
//
//        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: ASWIoTDataManager)
//        iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
    }
    
    func delayWithSecondsOnUI(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    
    func delayWithSecondsOnGlobal(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func getAWSClientID(completion: @escaping (_ clientId: String?,_ error: Error? ) -> Void) {
        // Depending on your scope you may still have access to the original credentials var
        let credentials = AWSCognitoCredentialsProvider(regionType: .APNortheast2, identityPoolId: "ap-northeast-2:dbf2e92e-a032-4b12-b28c-e74e378af20f")
        
        credentials.getIdentityId().continueWith(block: { (task:AWSTask<NSString>) -> Any? in
            if let error = task.error as NSError? {
                print("Failed to get client ID => \(error)")
                completion(nil, error)
                return nil  // Required by AWSTask closure
            }
            
            let clientId = task.result! as String
            self.clientId = clientId
            print("Got client ID => \(clientId)")
            completion(clientId, nil)
            return nil // Required by AWSTask closure
        })
    }
    
    func connectToAWSIoT(clientId: String!) {
        
        func mqttEventCallback(_ status: AWSIoTMQTTStatus ) {
            switch status {
            case .connecting: print("Connecting to AWS IoT")
            case .connected:
                print("Connected to AWS IoT")
                // Register subscriptions here
                self.registerSubscriptions()
                // Publish a boot message if required
            case .connectionError: print("AWS IoT connection error")
            case .connectionRefused: print("AWS IoT connection refused")
            case .protocolError: print("AWS IoT protocol error")
            case .disconnected: print("AWS IoT disconnected")
            case .unknown: print("AWS IoT unknown state")
            default: print("Error - unknown MQTT state")
            }
        }
        
        // Ensure connection gets performed background thread (so as not to block the UI)
        DispatchQueue.global(qos: .background).async {
            do {
                print("Attempting to connect to IoT device gateway with ID = \(clientId)")
                let dataManager = AWSIoTDataManager(forKey: "kDataManager")
                dataManager.connectUsingWebSocket(withClientId: clientId,
                                                  cleanSession: true,
                                                  statusCallback: mqttEventCallback)
                
            } catch {
//                print("Error, failed to connect to device gateway => \(error!)")
                print("Error, failed to connect to device gateway => ")
            }
        }
    }
    
    func registerSubscriptions() {
        print(123)
        func messageReceived(payload: Data) {
            print(1)
            let payloadDictionary = jsonDataToDict(jsonData: payload)
            print("Message received: \(payloadDictionary)")
//            self.payload = payloadDictionary
            
            // Handle message event here...
        }
        
        let updateDelta = "$aws/things/iotService/shadow/update/delta"
    
//        let topicArray = ["topicOne", "topicTwo", "topicThree"]
        let topicArray = [updateDelta]
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        
        for topic in topicArray {
            print("Registering subscription to => \(topic)")
            dataManager.subscribe(toTopic: topic,
                                  qoS: .messageDeliveryAttemptedAtMostOnce,  // Set according to use case
                                  messageCallback: messageReceived)
        }
    }

    func jsonDataToDict(jsonData: Data?) -> Dictionary <String, Any> {
            // Converts data to dictionary or nil if error
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: [])
                let convertedDict = jsonDict as! [String: Any]
                return convertedDict
            } catch {
                // Couldn't get JSON
                print(error.localizedDescription)
                return [:]
            }
    }
    
    func publishMessage(message: String!, topic: String!) {
      let dataManager = AWSIoTDataManager(forKey: "kDataManager")
      dataManager.publishString(message, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce) // Set QoS as needed
    }
}

