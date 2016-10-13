//
//  StartViewController.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 10/11/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit
import EasyToast
class StartViewController: UIViewController, FCMExecutiveDelegate{
    let TAG = "StartViewController:"
    var playerManager: PlayerManager?
    var cameraURL: String?
    
    @IBAction func liveButton(sender: AnyObject) {
        if cameraURL != nil {
            let parameters: NSMutableDictionary = NSMutableDictionary.init(capacity: 1)
            parameters[KxMovieParameterDisableDeinterlacing] = true
            let kxmovie = KxMovieViewController.movieViewControllerWithContentPath(cameraURL, parameters: parameters as [NSObject : AnyObject])
            presentViewController(kxmovie as! KxMovieViewController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        playerManager = PlayerManager.sharedInstance()
        setupCameraURL()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func restartLiveStream() {
        setupCameraURL()
        self.view.showToast("Doorbell URL updated! Please reconnect!", position: .Bottom, popTime: 3, dismissOnTap: false)
    }
    
    private func setupCameraURL(){
        let dic = playerManager?.dictionarySetting["Setup Camera"] as! NSDictionary
        if let URL = dic["URL"]{
        cameraURL = URL as? String
        }
        print("\(TAG) camera URL: \(cameraURL)")
        FCMExecutive.sharedInstance().delegate = self
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
