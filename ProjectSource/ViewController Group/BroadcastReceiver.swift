//
//  BroadcastReceiver.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 10/24/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol BCRDelegate{
    func showToast(message: String)
    func updateCameraURL()
}

class BroadcastReceiver: NSObject, GCDAsyncUdpSocketDelegate{
    var eventMessage = S_EVENTMSG_LOGIN_REQ.init()
    var isConnected = false
    var retry = 3
    let socketQueue = DispatchQueue(label: "SocketUDPQueue")
    let serverIP = "192.168.8.255"
    let serverPort: UInt16 = 5543
    let TAG = "BroadcastReceiver"
    //delegate
    var delegate: BCRDelegate?
    var dataSource: BCRDelegate?
    var bcrSocket: GCDAsyncUdpSocket?
    fileprivate static var instance: BroadcastReceiver?
    static func sharedInstance() -> BroadcastReceiver{
        if instance == nil{
            instance = BroadcastReceiver()
        }
        return instance!
    }
    
    fileprivate override init(){
        super.init()
        print("\(TAG): init")
        bcrSocket = GCDAsyncUdpSocket.init(socketQueue: socketQueue)
        bcrSocket?.setDelegate(self)
        bcrSocket?.setDelegateQueue(DispatchQueue.main)
        isConnected = false
    }
    
    //MARK: GCDAsyncUDPSocket delegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("\(TAG): didConnectToAddress")
        isConnected = true
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        print("\(TAG): didNotConnect")
        isConnected = false
        if retry >= 0 {
            retry -= 1
            do {
                try bcrSocket?.bind(toPort: serverPort)
                try bcrSocket?.beginReceiving()
            } catch {
                print("\(TAG): did not connect, retry count: \(retry)")
            }
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if data.count == 344 {
            let data = data as NSData
            let eventMessage = UnsafeMutablePointer<S_EVENTMSG_LOGIN_REQ>.allocate(capacity: MemoryLayout<S_EVENTMSG_LOGIN_REQ>.size)
            data.getBytes(eventMessage, length: MemoryLayout<S_EVENTMSG_LOGIN_REQ>.size)
            setupCameraFromUDP(eventMessage: eventMessage.move())
        }
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("\(TAG): didSendDataWithTag")
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("\(TAG): udpSocketDidClose")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("\(TAG): didNotSendDataWithTag")
    }
    
    //MARK: public functions
    func openBCReceiver() {
        print("\(TAG): openBCReceiver")
        do {
            try bcrSocket?.bind(toPort: serverPort)
            try bcrSocket?.beginReceiving()
        } catch  {
            print("\(TAG): openBCReceiver catch exception")
        }
    }
    
    //MARK: public functions
    func setupCameraFromUDP(eventMessage: S_EVENTMSG_LOGIN_REQ){
        let privateIP = eventMessage.u32DevPrivateIP
        let publicIP = eventMessage.u32DevPrivateIP
        let httpPort = String(eventMessage.u32DevHTTPPort)
        let rtspPort = String(eventMessage.u32DevRTSPPort)
        let cameraDic = PlayerManager.sharedInstance().dictionarySetting.object(forKey: "Setup Camera") as! NSMutableDictionary

        let publicIPTemp = String(format: "publicIP: %llu", publicIP)
        print("temp: \(publicIPTemp)")
        cameraDic.setValue(ipConversion(number: publicIP), forKey: "PublicIPAddr")
        cameraDic.setValue(ipConversion(number: privateIP), forKey: "PrivateIPAddr")
        cameraDic.setValue(httpPort, forKey: "HTTPPort")
        cameraDic.setValue(rtspPort, forKey: "RTSPPort")
        modifyURLWithIP()
        print("cameraDic: \(cameraDic)")
        delegate?.showToast(message: "Doorbell parameters updated")
    }
    
    func ipConversion(number: UInt32) -> String {
        var string = "-1"
        var a: in_addr = in_addr.init()
        a.s_addr = number.bigEndian
        let remote: UnsafeMutablePointer<Int8> = UnsafeMutablePointer.allocate(capacity: Int(INET_ADDRSTRLEN))
        inet_ntop(AF_INET, &(a.s_addr), remote, socklen_t(INET_ADDRSTRLEN))
        string = NSString.init(utf8String: remote) as! String
        return string
    }
    
    func modifyURLWithIP(){
        let cameraDic = PlayerManager.sharedInstance().dictionarySetting["Setup Camera"] as! NSMutableDictionary
        let cameraIP = cameraDic["PublicIPAddr"] as! String
        let URL: String = cameraDic["URL"] as! String
        let splitArray = URL.components(separatedBy: "/")
        if splitArray.count > 1{
            let oldIP = splitArray[2]
            let newURL = URL.replacingOccurrences(of: oldIP, with: cameraIP)
            print("newURL: \(newURL)")
            cameraDic.setValue(newURL, forKey: "URL")
            PlayerManager.sharedInstance().updateSettingPropertyList()
        }
    }
}
