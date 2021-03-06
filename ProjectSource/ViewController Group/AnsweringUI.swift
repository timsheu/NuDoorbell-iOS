//
//  AnsweringUI.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 10/13/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit

@objc class AnsweringUI: UIView {
    var deviceID: NSNumber = 0
    let TAG = "AnsweringUI"
    var isAnswer = false
    @IBOutlet var callingView: UIView!
    @IBOutlet var hangUpButton: UIButton!
    @IBOutlet var answerButton: UIButton!
    
    @IBAction func answer(_ sender: AnyObject){
        print("\(TAG): answer button")
        if isAnswer == false {
            isAnswering(option: true)
        }
    }
    @IBAction func hangUp(_ sender: AnyObject) {
        print("\(TAG): hangUp button")
        if isAnswer == true{
            isAnswering(option: false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    fileprivate func setupView(){
        callingView = loadViewFromNid()
        callingView.frame = bounds
        callingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hangUpButton.layer.masksToBounds = true
        hangUpButton.layer.cornerRadius = 15
        hangUpButton.isEnabled = false
        answerButton.layer.masksToBounds = true
        answerButton.layer.cornerRadius = 15
        addSubview(callingView)
    }
    
    fileprivate func loadViewFromNid() -> UIView{
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AnsweringUI", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func isAnswering(option: Bool){
        answerButton.isEnabled = !option
        hangUpButton.isEnabled = option
        isAnswer = option
        let result = DeviceData.query().where(withFormat: "id = %@", withParameters: [deviceID]).fetch()
        let deviceData = result?[0] as! DeviceData
        let isHTTP = deviceData.isVoiceUploadHttp;
        let cameraIP = deviceData.publicIP!
        let port = deviceData.httpPort
        print("isAnswering: \(isHTTP), \(cameraIP), \(port), \n\(deviceData.toString())")
        if isHTTP == true {
            if option == true {
                (AudioRecorder.sharedInstance() as AnyObject).startRecordingMicHttp(cameraIP, port: UInt16(80))
            }else{
                (AudioRecorder.sharedInstance() as AnyObject).stopRecordingMicHttp()
            }
        }else{
            if option == true {
                (AudioRecorder.sharedInstance() as AnyObject).startRecordingMic(deviceID)
            }else {
                (AudioRecorder.sharedInstance() as AnyObject).stopRecordingMic()
            }
        }
    }
    
    func setDeviceID(deviceID: NSNumber){
        self.deviceID = deviceID
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
