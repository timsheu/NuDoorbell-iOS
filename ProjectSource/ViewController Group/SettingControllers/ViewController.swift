//
//  ViewController.swift
//  customButton
//
//  Created by CCHSU20 on 11/11/2016.
//  Copyright © 2016 CCHSU20. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EditDBTableDelegate{
    var items = Array<[String: Any]>()
    var onClickIndex: IndexPath?
    @IBOutlet weak var collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        for result in DeviceData.query().fetch(){
            let device = result as! DeviceData
            let name = device.name
            let id = device.id
            let publicIP = device.publicIP
            let privateIP = device.privateIP
            let type = device.deviceType
            let item: [String: Any] = ["name": name!, "id": id!, "publicIP": publicIP!, "privateIP": privateIP!, "type": type!]
            print("Dic: \(item)")
            items.append(item)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = Int(DeviceData.query().count())
        return count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = "Cell"
        if indexPath.item == self.items.count {
            identifier = "Plus"
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if identifier == "Cell" {
            let label: UILabel = cell.viewWithTag(10) as! UILabel
            let indicator: UIImageView = cell.viewWithTag(11) as! UIImageView
            let button: UIImageView = cell.viewWithTag(12) as! UIImageView
            let dic = self.items[indexPath.item]
            label.text = dic["name"] as? String
            indicator.image = UIImage(named: "STATUS_R")
            button.image = UIImage(named: "db")
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.singleTap(gesture:)))
            let long = UILongPressGestureRecognizer.init(target: self, action: #selector(ViewController.longPress(gesture:)))
            cell.addGestureRecognizer(tap)
            cell.addGestureRecognizer(long)
        }else {
            // identifier == "Plus" do not need to be handled
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 108, height: 108)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let table = segue.destination as! EditDBTableViewController
        var dic = [String: Any]();
        table.delegate = self
        if segue.identifier == "Edit" {
            dic = items[(onClickIndex?.item)!]
        }
        table.passData(dictionary: dic)
    }
    
    //MARK: SetDBTable delegate
    func setDevice(setting: [String : String]) {
        NSLog("SetDevice: %@", setting)
        let deviceData = DeviceData();
        deviceData.name = setting["name"]!
        deviceData.deviceType = setting["type"]!
        deviceData.publicIP = setting["publicIP"]!
        deviceData.privateIP = setting["publicIP"]!
        _ = deviceData.commit()
        print("device count: \(DeviceData.query().count())")
        var dic = setting
        dic["id"] = String.init(describing: deviceData.id)
        items.append(dic)
        collection.reloadData()
    }
    
    //MARK: EditDBTable delegate
    func editDevice(setting: [String: Any]) {
        print("editDevice: \(setting)")
        if let row = setting["id"]{
            let queryString = String(format: "id = %@", row as! NSNumber)
            let result = DeviceData.query().where(queryString).fetch()
            print("\(setting)")
            let deviceData = result?[0] as! DeviceData
            deviceData.name = setting["name"] as? String
            deviceData.deviceType = setting["type"] as? String
            deviceData.publicIP = setting["publicIP"] as? String
            deviceData.privateIP = setting["publicIP"] as? String
            _ = deviceData.commit()
            
            var item = items[(onClickIndex?.item)!]
            item["type"] = setting["type"] as! String
            item["name"] = setting["name"] as! String
            item["publicIP"] = setting["publicIP"] as! String
            item["privateIP"] = setting["publicIP"] as! String
            items[(onClickIndex?.item)!] = item
        }else{
            let deviceData = DeviceData();
            deviceData.name = setting["name"] as? String
            deviceData.deviceType = setting["type"] as? String
            deviceData.publicIP = setting["publicIP"] as? String
            deviceData.privateIP = setting["publicIP"] as? String
            _ = deviceData.commit()
            print("device count: \(DeviceData.query().count())")
            var item = setting
            item["id"] = deviceData.id
            items.append(item)
        }
        collection.reloadData()
    }
    
    //MARK: short/long click event
    func singleTap(gesture: UITapGestureRecognizer){
//        print("\(gesture.location(in: collection))" + " tap")
        let point = gesture.location(in: collection)
        let indexpath = collection.indexPathForItem(at: point)
        onClickIndex = indexpath
        let item = items[(onClickIndex?.item)!]
        if let ip = item["publicIP"]{
            let ip = ip as! String
            let cameraURL = "rtsp" + ip + "/cam1/h264"
            let parameters = [KxMovieParameterDisableDeinterlacing:true]
            let deviceID: NSNumber = item["id"] as! NSNumber
            let kxmovie = KxMovieViewController.movieViewController(withContentPath: cameraURL, parameters: parameters as [AnyHashable: Any], deviceID: deviceID)
            present(kxmovie as! KxMovieViewController, animated: true, completion: nil)
        }

    }
    
    func longPress(gesture: UILongPressGestureRecognizer){
//        print("\(gesture.location(in: collection))" + " press")
        let point = gesture.location(in: collection)
        let indexpath = collection.indexPathForItem(at: point)
        onClickIndex = indexpath
        if  gesture.state == .began{
            let alert = UIAlertController(title: "Device Option", message: "Select action for next step", preferredStyle: .actionSheet)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            let remove = UIAlertAction(title: "Remove", style: .destructive, handler: { UIAlertAction in
                let item = self.items[(self.onClickIndex?.item)!]
                let id = item["id"] as! NSNumber
                if let result = DeviceData.query().where(withFormat: "id = %@", withParameters: [id]).fetch(){
                    let device = result[0] as! DeviceData
                    device.remove()
                    device.commit()
                }
                self.items.remove(at: (self.onClickIndex?.item)!)
                self.collection.reloadData()
            })
            alert.addAction(remove)
            
            let edit = UIAlertAction(title: "Edit", style: .default, handler: { UIAlertAction in
                self.performSegue(withIdentifier: "Edit", sender: nil)
            })
            alert.addAction(edit)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
}

