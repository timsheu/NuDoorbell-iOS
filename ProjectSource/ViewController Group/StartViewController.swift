//
//  StartViewController.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 10/11/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, FCMExecutiveDelegate, BCRDelegate{
    let TAG = "StartViewController:"
    var playerManager: PlayerManager?
    var cameraURL: String?
    
    @IBAction func liveButton(_ sender: AnyObject) {
        if cameraURL != nil {
            let parameters = [KxMovieParameterDisableDeinterlacing:true]
            
            let kxmovie = KxMovieViewController.movieViewController(withContentPath: cameraURL, parameters: parameters as [AnyHashable: Any])
            present(kxmovie as! KxMovieViewController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        playerManager = PlayerManager.sharedInstance()
        setupCameraURL()
        BroadcastReceiver.sharedInstance().delegate = self
        BroadcastReceiver.sharedInstance().openBCReceiver()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func restartLiveStream() {
        setupCameraURL()
        
//        self.view.showToast("Doorbell URL updated! Please reconnect!", duration: 3, position: .Bottom, completion: false)
    }
    
    func openLiveStream() {
        let dummy = ""
        let alert = UIAlertController(title: "Ringing!", message: "Doorbell is ringing, show live stream now?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Nope.", style: .default, handler: nil)
        let stream = UIAlertAction(title: "Now Thanks!", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.liveButton(dummy as AnyObject)
        })
        alert.addAction(cancel)
        alert.addAction(stream)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupCameraURL(){
        let dic = playerManager?.dictionarySetting["Setup Camera"] as! NSDictionary
        if let URL = dic["URL"]{
        cameraURL = URL as? String
        }
        print("\(TAG) camera URL: \(cameraURL)")
        FCMExecutive.sharedInstance().delegate = self
    }
    
    //MARK: BCRDelegate
    func showToast(message: String) {
        self.view.makeToast(message)
    }
    
    func updateCameraURL() {
        let cameraDic = playerManager?.dictionarySetting["Setup Camera"] as! NSMutableDictionary
        if let URL = cameraDic["URL"]{
            cameraURL = URL as? String
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
