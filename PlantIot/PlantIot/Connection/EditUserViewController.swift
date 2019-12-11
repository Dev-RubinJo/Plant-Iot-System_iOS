//
//  EditUserViewController.swift
//  PlantIot
//
//  Created by 우소연 on 10/12/2019.
//  Copyright © 2019 YoobinJo. All rights reserved.
//

import UIKit

class EditUserViewController: UIViewController, UIPickerViewDataSource {
    var selectrow = 0
    private let values: [String] = ["다육이","관엽식물","허브","덩굴식물","꽃"]
    
    @IBAction func cancelBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var specLbl: UILabel!{
        didSet{
            specLbl.text = ""
        }
    }
    @IBOutlet weak var specBtn: UIButton!{
        didSet{
            specBtn.setTitle("종 선택", for: .normal)
            specBtn.setTitleColor(UIColor.green, for: .normal)
        }
    }
    @IBAction func specBtn(_ sender: Any) {
        if(specBtn.currentTitleColor == UIColor.green){
            //specBtn.backgroundColor = UIColor.red
            specBtn.setTitleColor(UIColor.red, for: .normal)
            pickerview.isHidden = false
            specLbl.text = values[selectrow]
            nextBtn.isEnabled = true
        }else{
            // specBtn.backgroundColor = UIColor.white
            specBtn.setTitleColor(UIColor.green, for: .normal)
            pickerview.isHidden = true
            specLbl.text = values[selectrow]
            nextBtn.isEnabled = true
        }
    }
    
    @IBOutlet weak var pickerview: UIPickerView!{
        didSet{
            pickerview.isHidden = true
        }
    }
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!{
        didSet{
            nextBtn.isEnabled = false
        }
    }
    
    @IBAction func pushBtn(_ sender: Any) {
        if(textField.text != ""){
            UserDefaults.standard.set(textField.text, forKey: "name")
            UserDefaults.standard.set(specLbl.text, forKey: "spec")
            self.navigationController!.pushViewController(ConnectDynamoViewController(), animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        pickerview.isHidden = true
        pickerview.delegate = self
        pickerview.dataSource = self
        // Do any additional setup after loading the view.
    }
}
extension EditUserViewController: UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // Data source method that returns the number of rows to display in the picker.
    // (Implementation required)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    // Delegate method that returns the value to be displayed in the picker.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row]
    }
    // A method called when the picker is selected.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectrow = row
    }
    
}
