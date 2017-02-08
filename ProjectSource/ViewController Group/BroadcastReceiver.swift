//
//  BroadcastReceiver.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 10/24/16.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit

protocol BroadcastReceiverDelegate{
    func showToast(message: String)
    func gotRingMessage(uuid: String)
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
    var delegate: BroadcastReceiverDelegate?
    var dataSource: BroadcastReceiverDelegate?
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
        let data = data as NSData
        let subData = data.subdata(with: NSRange.init(location: 0, length: 12)) as NSData
        let headerTemp = UnsafeMutablePointer<S_EVENTMSG_HEADER>.allocate(capacity: MemoryLayout<S_EVENTMSG_HEADER>.size)
        subData.getBytes(headerTemp, length: MemoryLayout<S_EVENTMSG_HEADER>.size)
        let header = headerTemp.move()
        
        if header.eMsgType == eEVENTMSG_LOGIN.rawValue {
            let loginMessage = UnsafeMutablePointer<S_EVENTMSG_LOGIN_REQ>.allocate(capacity: MemoryLayout<S_EVENTMSG_LOGIN_REQ>.size)
            data.getBytes(loginMessage, length: MemoryLayout<S_EVENTMSG_LOGIN_REQ>.size)
            setupCameraFromUDP(eventMessage: loginMessage.move())
        }else if header.eMsgType == eEVENTMSG_EVENT_NOTIFY.rawValue{
            let ringMessage = UnsafeMutablePointer<S_EVENTMSG_EVENT_NOTIFY>.allocate(capacity: MemoryLayout<S_EVENTMSG_EVENT_NOTIFY>.size)
            data.getBytes(ringMessage, length: MemoryLayout<S_EVENTMSG_EVENT_NOTIFY>.size)
            let uuid = String(describing: ringMessage.move().szUUID)
            delegate?.gotRingMessage(uuid: uuid)
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
    func openBroadcastReceiver() {
        print("\(TAG): openBroadcastReceiver")
        do {
            try bcrSocket?.bind(toPort: serverPort)
            try bcrSocket?.beginReceiving()
        } catch  {
            print("\(TAG): openBCReceiver catch exception")
        }
    }
    
    //MARK: public functions
    func setupCameraFromUDP(eventMessage: S_EVENTMSG_LOGIN_REQ){
        let uuid = String(describing: eventMessage.szUUID)
        let privateIP = eventMessage.u32DevPrivateIP
        let publicIP = eventMessage.u32DevPrivateIP
        let httpPort = eventMessage.u32DevHTTPPort
        let rtspPort = eventMessage.u32DevRTSPPort
        let result = DeviceData.query().where(withFormat: "uuid = %@", withParameters: [uuid]).fetch()
        switch (result?.count)! {
        case 0:
            let newDevice = DeviceData.init()
            newDevice.uuid = uuid
            newDevice.publicIP = ipConversion(number: publicIP)
            newDevice.privateIP = ipConversion(number: privateIP)
            newDevice.httpPort = Int(httpPort)
            newDevice.rtspPort = Int(rtspPort)
            newDevice.commit()
            break;
        case 1:
            let newDevice = result?[0] as! DeviceData
            newDevice.publicIP = ipConversion(number: publicIP)
            newDevice.privateIP = ipConversion(number: privateIP)
            newDevice.httpPort = Int(httpPort)
            newDevice.rtspPort = Int(rtspPort)
            newDevice.commit()
            break;
        default:
            print("one uuid with more than one device, error!!")
            break;
        }
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
    
}
