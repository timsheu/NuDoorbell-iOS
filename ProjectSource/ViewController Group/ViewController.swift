//
//  ViewController.swift
//  customButton
//
//  Created by CCHSU20 on 11/11/2016.
//  Copyright © 2016 CCHSU20. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetDBTableDelegate{
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    @IBOutlet weak var collection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var identifier = "Cell"
        if indexPath.item == self.items.count - 1 {
            identifier = "Plus"
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if identifier == "Cell" {
            let label: UILabel = cell.viewWithTag(10) as! UILabel
            let indicator: UIImageView = cell.viewWithTag(11) as! UIImageView
            let button: UIImageView = cell.viewWithTag(12) as! UIImageView
            label.text = self.items[indexPath.item]
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
        if segue.identifier == "Plus" {
            let table = segue.destination as! SetDBTableViewController
            table.delegate = self
        }
    }
    
    //MARK: SetDBTable delegate
    func setDevice(setting: [String : String]) {
        NSLog("SetDevice: %@", setting)
        items.append(setting["name"]!)
        collection.reloadData()
    }
    
    //MARK: short/long click event
    @IBAction func singleTap(gesture: UITapGestureRecognizer){
        print("\(gesture.location(in: collection))" + " tap")
        let point = gesture.location(in: collection)
        let indexpath = collection.indexPathForItem(at: point)
    }
    
    @IBAction func longPress(gesture: UILongPressGestureRecognizer){
        print("\(gesture.location(in: collection))" + " press")
        let point = gesture.location(in: collection)
        let indexpath = collection.indexPathForItem(at: point)
    }
}

