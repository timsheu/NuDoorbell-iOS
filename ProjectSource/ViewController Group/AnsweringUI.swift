//
//  AnsweringUI.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 10/13/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit
import EasyToast
@objc class AnsweringUI: UIView {
    let TAG = "AnsweringUI"
    var isAnswer = false
    @IBOutlet var callingView: UIView!
    @IBOutlet var hangUpButton: UIButton!
    @IBOutlet var answerButton: UIButton!
    
    @IBAction func answer(sender: AnyObject){
        print("\(TAG): answer button")
        if isAnswer == false {
            answerButton.enabled = false
            hangUpButton.enabled = true
            isAnswer = true
            AudioRecorder.sharedInstance().startRecordingMic()
        }
    }
    @IBAction func hangUp(sender: AnyObject) {
        print("\(TAG): hangUp button")
        if isAnswer == true{
            answerButton.enabled = true
            hangUpButton.enabled = false
            isAnswer = false
            AudioRecorder.sharedInstance().stopRecordingMic()
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
    
    private func setupView(){
        callingView = loadViewFromNid()
        callingView.frame = bounds
        callingView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        hangUpButton.layer.masksToBounds = true
        hangUpButton.layer.cornerRadius = 15
        hangUpButton.enabled = false
        answerButton.layer.masksToBounds = true
        answerButton.layer.cornerRadius = 15
        addSubview(callingView)
    }
    
    private func loadViewFromNid() -> UIView{
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "AnsweringUI", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
