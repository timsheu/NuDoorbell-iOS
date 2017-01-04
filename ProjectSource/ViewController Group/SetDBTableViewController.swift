//
//  SetDBTableViewController.swift
//  customButton
//
//  Created by CCHSU20 on 28/12/2016.
//  Copyright © 2016 CCHSU20. All rights reserved.
//

import UIKit
protocol SetDBTableDelegate {
    func setDevice(setting: [String: String])
}
class SetDBTableViewController: UITableViewController, UITextFieldDelegate {
    
    var delegate: SetDBTableDelegate?
    var nameTextField: UITextField?
    var urlTextField: UITextField?
    var typeSegment: UISegmentedControl?
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "Text"
        switch indexPath.item {
        case 0...1:
            identifier = "Text"
            break;
        case 2:
            identifier = "Selection"
            break;
        default:
            identifier = "Option"
            break;
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch indexPath.item {
        case 0:
            let label = cell.viewWithTag(30) as! UILabel
            label.text = "Name"
            nameTextField = cell.viewWithTag(31) as? UITextField
            nameTextField?.delegate = self
            nameTextField?.text = "NuDoorbell"
            break;
        case 1:
            let label = cell.viewWithTag(30) as! UILabel
            label.text = "URL"
            urlTextField = cell.viewWithTag(31) as? UITextField
            urlTextField?.delegate = self
            urlTextField?.text = "192.168.100.1"
            break;
        case 2:
            let label = cell.viewWithTag(32) as! UILabel
            label.text = "Type"
            typeSegment = cell.viewWithTag(33) as? UISegmentedControl
            typeSegment?.addTarget(self, action: #selector(SetDBTableViewController.segmentedValueChanged(_:)), for: .valueChanged)
            break;
        default:
            break;
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
    @IBAction func cancelSave(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveDevice(_ sender: Any) {
    
        let name = nameTextField?.text
        let url = urlTextField?.text
        var type: String = "NuDoorbell"
        if typeSegment?.selectedSegmentIndex == 1 {
            type = "SkyEye"
        }else if typeSegment?.selectedSegmentIndex == 2{
            type = "NuWicam"
        }
        let map = ["name": name, "url": url, "type": type]
        delegate?.setDevice(setting: map as! [String : String])
        _ = navigationController?.popViewController(animated: true)
    
    }
    
    //MARK: Segmented Control
    func segmentedValueChanged(_ sender: Any){
        let index = (typeSegment?.selectedSegmentIndex)! as Int
        switch index {
        case 0:
            nameTextField?.text = "NuDoorbell"
            break;
        case 1:
            nameTextField?.text = "SkyEye"
            break;
        case 2:
            nameTextField?.text = "NuWicam"
        default:
            break;
        }
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
