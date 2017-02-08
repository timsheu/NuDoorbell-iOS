//
//  EditDBTableViewController.swift
//  customButton
//
//  Created by CCHSU20 on 28/12/2016.
//  Copyright © 2016 CCHSU20. All rights reserved.
//

import UIKit
protocol EditDBTableDelegate {
    func editDevice(setting: [String: Any])
}
class EditDBTableViewController: UITableViewController, UITextFieldDelegate, HTTPSocketDelegate {
    var deviceData :DeviceData?
    var delegate: EditDBTableDelegate?
    var nameTextField: UITextField?
    var urlTextField: UITextField?
    var uuidTextField: UITextField?
    var wifiTextField: UITextField?
    var passwordTextFiled: UITextField?
    var typeSegment: UISegmentedControl?
    var data: NSData?
    
    let httpSocketManager = HTTPSocketManager.sharedInstance
    var receiveDictionary = [String: Any]()
    let headerArray = ["Basic Information", "Video", "Audio", "Wi-Fi", "Restart"]
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        saveDevice()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        httpSocketManager.delegate = self
        if let id = receiveDictionary["id"]{
            let result = DeviceData.query().where(withFormat: "id = %@", withParameters: [id]).fetch()
            if (result?.count)! > 0 {
                deviceData = result?[0] as? DeviceData
            }
        }else {
            deviceData = DeviceData.init()
            deviceData?.commit()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headerArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 4
        switch section {
        case 1:
            rows = 2
            break
        case 2:
            rows = 1
            break
        case 3:
            rows = 2
            break
        case 4:
            rows = 1
            break
        default:
            break
        }
        // #warning Incomplete implementation, return the number of rows
        return rows
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = "Basic Information"
        switch section {
        case 1:
            title = "Video"
            break
        case 2:
            title = "Audio"
            break
        case 3:
            title = "Wi-Fi"
            break
        default:
            title = "System"
            break;
        }
        // #warning Incomplete implementation, return the number of rows
        return title
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell.init()
        if indexPath.section == 0 {
            var identifier = "Text"
            switch indexPath.item {
            case 0...2:
                identifier = "Text"
                break;
            case 3:
                identifier = "Selection"
                break;
            default:
                identifier = "Option"
                break;
            }
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            
            switch indexPath.item {
            case 0:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Name"
                nameTextField = cell.viewWithTag(31) as? UITextField
                nameTextField?.delegate = self
                if let name = receiveDictionary["name"]{
                    nameTextField?.text = name as? String
                }else {
                    nameTextField?.text = "NuDoorbell"
                }
                nameTextField?.addTarget(self, action: #selector(EditDBTableViewController.endEditingName(_:)), for: .editingDidEnd)
                break
            case 1:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "URL"
                urlTextField = cell.viewWithTag(31) as? UITextField
                urlTextField?.delegate = self
                if let publicIP = receiveDictionary["publicIP"] {
                    urlTextField?.text = publicIP as? String
                }else{
                    urlTextField?.text = "192.168.100.1"
                }
                urlTextField?.addTarget(self, action: #selector(EditDBTableViewController.endEditingURL(_:)), for: .editingDidEnd)
                break;
            case 2:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "UUID"
                uuidTextField = cell.viewWithTag(31) as? UITextField
                uuidTextField?.delegate = self
                uuidTextField?.text = deviceData?.uuid
                break;
            case 3:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Type"
                typeSegment = cell.viewWithTag(33) as? UISegmentedControl
                if let type = receiveDictionary["type"]{
                    let type = type as! String
                    switch type {
                    case "NuDoorbell":
                        typeSegment?.selectedSegmentIndex = 0
                        break
                    case "SkyEye":
                        typeSegment?.selectedSegmentIndex = 1
                        break
                    case "NuWicam":
                        typeSegment?.selectedSegmentIndex = 2
                        break
                    default:
                        break
                    }
                }else{
                    typeSegment?.selectedSegmentIndex = 0
                }
                typeSegment?.addTarget(self, action: #selector(EditDBTableViewController.segmentedValueChanged(_:)), for: .valueChanged)
                break;
            default:
                break;
            }
        }else if indexPath.section == 1{
            var identifier = "Text"
            switch indexPath.item {
            case 0:
                identifier = "Selection"
                break;
            default:
                identifier = "Slider"
                break;
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            
            switch indexPath.item {
            case 0:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Resolution"
                let resolutionSegment = cell.viewWithTag(33) as? UISegmentedControl
                resolutionSegment?.setTitle("QVGA", forSegmentAt: 0)
                resolutionSegment?.setTitle("VGA", forSegmentAt: 1)
                resolutionSegment?.setTitle("360p", forSegmentAt: 2)
                resolutionSegment?.addTarget(self, action: #selector(EditDBTableViewController.resolutionSegmentValueChanged), for: .valueChanged)
                break;
            case 1:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Bit Rate"
                let bitRateSlider = cell.viewWithTag(34) as? UISlider
                bitRateSlider?.maximumValue = 4096
                bitRateSlider?.minimumValue = 0
                bitRateSlider?.value = Float((deviceData?.bitRate)!)
                bitRateSlider?.addTarget(self, action: #selector(EditDBTableViewController.bitRateSliderValueEnd(_:)), for: .touchUpInside)
                break;
            default:
                break;
            }
        }else if indexPath.section == 2{
            var identifier = "Text"
            if indexPath.item == 0 {
                identifier = "Selection"
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            
            switch indexPath.item {
            case 0:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Voice Upload"
                let audioSegment = cell.viewWithTag(33) as? UISegmentedControl
                audioSegment?.setTitle("HTTP", forSegmentAt: 0)
                audioSegment?.setTitle("Socket", forSegmentAt: 1)
                audioSegment?.removeSegment(at: 2, animated: false)
                if (deviceData?.isVoiceUploadHttp)! {
                    audioSegment?.selectedSegmentIndex = 0
                }else {
                    audioSegment?.selectedSegmentIndex = 1
                }
                audioSegment?.addTarget(self, action: #selector(EditDBTableViewController.voiceHttpSegmentChanged(_:)), for: .valueChanged)
                break;
            default:
                break;
            }
        }else if indexPath.section == 3{
            var identifier = "Text"
            if indexPath.item == 2{
                identifier = "Restart"
            }
            
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            
            switch indexPath.item {
            case 0:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "SSID"
                let text = cell.viewWithTag(31) as! UITextField
                text.addTarget(self, action: #selector(EditDBTableViewController.endEditingSSID(_:)), for: .editingDidEnd)
                text.text = deviceData?.ssid
                text.delegate = self
                break;
            case 1:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Password"
                let text = cell.viewWithTag(31) as! UITextField
                text.addTarget(self, action: #selector(EditDBTableViewController.endEditingPassword(_:)), for: .editingDidEnd)
                text.text = deviceData?.password
                text.delegate = self
                break;
            default:
                break;
            }
        }else if indexPath.section == 4{
            let identifier = "Restart"
            
            cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            
            switch indexPath.item {
            case 0:
                let label = cell.viewWithTag(30) as! UILabel
                label.text = "Restart"
                let restartButton = cell.viewWithTag(36) as? UIButton
                restartButton?.setTitle("Click to open menu", for: .normal)
                restartButton?.addTarget(self, action: #selector(EditDBTableViewController.openRestartMenu(_:)), for: UIControlEvents.touchDown)
                break;
            default:
                break;
            }

        }
        
        
        // Configure the cell...
        
        return cell
    }
    
    //MARK: text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: button action
    @IBAction func saveDevice() {
        let name = nameTextField?.text
        let url = urlTextField?.text
        let uuid = uuidTextField?.text
        var type: String = "NuDoorbell"
        if typeSegment?.selectedSegmentIndex == 1 {
            type = "SkyEye"
        }else if typeSegment?.selectedSegmentIndex == 2{
            type = "NuWicam"
        }
        
        var map = ["name": name!, "publicIP": url!, "type": type, "uuid": uuid!] as [String: Any]
        
        map["id"] = deviceData?.id
        
        map["isAlive"] = false
        
        print("Map: \(map)\n")
        delegate?.editDevice(setting: map)
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    //MARK: Segmented Control
    func segmentedValueChanged(_ sender: Any){
        let index = (typeSegment?.selectedSegmentIndex)! as Int
        var text = "NuDoorbell"
        if index == 1 {
            text = "SkyEye"
        }else{
            text = "NuWicam"
        }
        nameTextField?.text = text
        deviceData?.deviceType = text
    }
    
    func resolutionSegmentValueChanged(_ sender: Any){
        let segment = sender as! UISegmentedControl
        let value = segment.selectedSegmentIndex
        let valueString = String(value)
        var command = ""
        var resolutionString = "QVGA"
        if value == 1 {
            resolutionString = "VGA"
        }else {
            resolutionString = "360p"
        }
        deviceData?.resolution = resolutionString
        deviceData?.commit()
        switch (typeSegment?.selectedSegmentIndex)! {
        case 0:
            command = NuDoorbellCommand.setResolution(value: valueString)
            break
        case 1:
            let parameters = ["VINWIDTH": String(value*320), "VINHEIGHT": String(value*240), "JPEGENCWIDTH": String(value*320), "JPEGENCHEIGHT": String(value*240)]
            command = NuWicamCommand.updateStreamParameters(parameters: parameters)
            break
        default:
            command = NuPlayerCommand.setResolution(type: "h264", value: value)
            break
        }
        data = command.data(using: .utf8) as NSData?
        httpSocketManager.connect(host: (deviceData?.publicIP)!, port: (deviceData?.httpPort)!)
    }
    
    func bitRateSliderValueEnd(_ sender: Any){
        let slider = sender as! UISlider
        let value = Int(slider.value)
        switch value {
        case 0...1023:
            slider.value = 0
            break
        case 1024...2047:
            slider.value = 1024
            break
        case 2048...3071:
            slider.value = 2048
            break
        case 3072...4095:
            slider.value = 3072
            break
        default:
            slider.value = 4096
            break
        }
        let valueString = String(value)
        let deviceType = deviceData?.deviceType
        var command = ""
        switch deviceType! {
        case "NuDoorbell":
            command = NuDoorbellCommand.setEncodeBitrate(value: valueString)
            break
        case "NuWicam":
            let parameters = ["BITRATE": valueString]
            command = NuWicamCommand.updateStreamParameters(parameters: parameters)
            break
        default:
            command = NuPlayerCommand.setEncodeBitrate(type: "h264", value: value)
            break
        }
        
        data = command.data(using: .utf8) as NSData?
        httpSocketManager.connect(host: (deviceData?.publicIP)!, port: (deviceData?.httpPort)!)
    }
    
    func voiceHttpSegmentChanged(_ sender: Any){
        let segment = sender as! UISegmentedControl
        let value = segment.selectedSegmentIndex
        deviceData?.isVoiceUploadHttp = true
        if value == 1 {
            deviceData?.isVoiceUploadHttp = false
        }
        deviceData?.commit()
    }
    
    func openRestartMenu(_ sender: Any){
        let deviceType = deviceData?.deviceType
        var restartMenu = UIAlertController.init(title: "Restart Menu", message: "Is it okay to reboot the device?", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        restartMenu.addAction(cancel)
        
        if deviceType == "NuDoorbell" {
            let confirm = UIAlertAction.init(title: "Okay", style: .default, handler: { UIAlertAction
                in
                let command = NuDoorbellCommand.restart()
                self.data = command.data(using: .utf8) as NSData?
                self.httpSocketManager.connect(host: (self.deviceData?.publicIP)!, port: (self.deviceData?.httpPort)!)
            })
            restartMenu.addAction(confirm)
        }else if deviceType == "SkyEye"{
            let confirm = UIAlertAction.init(title: "Okay", style: .default, handler: { UIAlertAction
                in
                let command = NuPlayerCommand.reboot()
                self.data = command.data(using: .utf8) as NSData?
                self.httpSocketManager.connect(host: (self.deviceData?.publicIP)!, port: (self.deviceData?.httpPort)!)
            })
            restartMenu.addAction(confirm)
        }else if deviceType == "NuWicam"{
            restartMenu = UIAlertController.init(title: "Restart Menu", message: "Click any part of the device to reboot it", preferredStyle: .actionSheet)
            let restartStream = UIAlertAction.init(title: "Restart Stream", style: .default, handler: { UIAlertAction in
                let command = NuWicamCommand.restart(category: "stream")
                self.data = command.data(using: .utf8) as NSData?
                self.httpSocketManager.connect(host: (self.deviceData?.publicIP)!, port: (self.deviceData?.httpPort)!)
            })
            let restartWifi = UIAlertAction.init(title: "Restart Wi-Fi", style: .default, handler: { UIAlertAction in
                let command = NuWicamCommand.restart(category: "wifi")
                self.data = command.data(using: .utf8) as NSData?
                self.httpSocketManager.connect(host: (self.deviceData?.publicIP)!, port: (self.deviceData?.httpPort)!)
            })
            let restartBoard = UIAlertAction.init(title: "Restart Board", style: .default, handler: { UIAlertAction in
                let command = NuWicamCommand.restart(category: "board")
                self.data = command.data(using: .utf8) as NSData?
                self.httpSocketManager.connect(host: (self.deviceData?.publicIP)!, port: (self.deviceData?.httpPort)!)
            })
            restartMenu.addAction(restartStream)
            restartMenu.addAction(restartWifi)
            restartMenu.addAction(restartBoard)
        }
        self.present(restartMenu, animated: true, completion: nil)
    }
    
    func endEditingSSID(_ sender: Any) -> Void {
        let text = sender as! UITextField
        deviceData?.ssid = text.text!
        deviceData?.commit()
    }
    
    func endEditingPassword(_ sender: Any) -> Void {
        let text = sender as! UITextField
        deviceData?.password = text.text!
        deviceData?.commit()
    }
    
    func endEditingName(_ sender: Any) -> Void {
        let text = sender as! UITextField
        deviceData?.name = text.text!
        deviceData?.commit()
    }
    
    func endEditingURL(_ sender: Any) -> Void {
        let text = sender as! UITextField
        deviceData?.name = text.text!
        deviceData?.commit()
    }
    
    //MARK: HTTP Socket Manager Delegate
    func didConnected() {
        httpSocketManager.write(data: data as! Data)
    }
    
    func dataRead(data: Data) {
        print("\(data)")
    }
    
    //MARK: receive data from last controller
    func passData(dictionary: [String: Any]) -> Void {
        receiveDictionary = dictionary
        print("\(receiveDictionary)")
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
