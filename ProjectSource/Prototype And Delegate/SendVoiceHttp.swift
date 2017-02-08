//
//  SendVoiceHttp.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 12/12/2016.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

import UIKit

@objc protocol SendVoiceHttpDelegate {
    func didConnectedSendVoiceHttp()
}

class SendVoiceHttp: NSObject, GCDAsyncSocketDelegate {
    var delegate: SendVoiceHttpDelegate?
    let socketQueue = DispatchQueue(label: "HttpSocketQueue")
    let TAG = "SendVoiceHttp"
    var serverIP = "192.168.8.15"
    var httpPort: UInt16 = 80
    var socket: GCDAsyncSocket?
    
    //MARK: init
    init(ip: String, port: UInt16){
        super.init()
        serverIP = ip
        httpPort = port
        socket = GCDAsyncSocket.init(socketQueue: socketQueue)
        socket?.setDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    override init(){
        super.init()
        socket = GCDAsyncSocket.init(socketQueue: socketQueue)
        socket?.setDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    //MARK: Socket delegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("\(TAG): didConnectToHost")
        let command = "GET /audio.input?samplerate=8000&channel=1&volume=100 HTTP/1.1\r\n"
        let httpHeader = "Content-Type: audio/l16\r\nContent-Length: 268435455\r\n\r\n"
        let temp = command + httpHeader;
        socket?.write(temp.data(using: .utf8)!, withTimeout: -1, tag: 0);
        delegate?.didConnectedSendVoiceHttp()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("\(TAG): socketDidDisconnect")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("\(TAG): didRead")
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("\(TAG): didWriteDataWithTag")
    }
    
    //MARK: utility
    func writeVoiceData(data: NSData) -> Void {
//        if (socket?.isConnected)! {
            socket?.write(data as Data, withTimeout: -1, tag: 0)
//        }
    }
    
    func connectVoiceHttpSocket() -> Void {
        do {
            print("serverIP: \(serverIP), httpPort: \(httpPort)")
            try socket?.connect(toHost: serverIP, onPort: httpPort)
        } catch {
            print("\(TAG): server connect fail")
        }
    }
    
    func setSendVoiceHttpDelegate(delegate: SendVoiceHttpDelegate) -> Void {
        self.delegate = delegate
    }
    
    func setIP(ip: String) -> Void {
        self.serverIP = ip
    }
    
    func setPort(port: UInt16) -> Void {
        self.httpPort = port
    }
    
    func setupSVH(ip: String, port: UInt16) -> Void {
        self.serverIP = ip
        self.httpPort = port
    }
}
