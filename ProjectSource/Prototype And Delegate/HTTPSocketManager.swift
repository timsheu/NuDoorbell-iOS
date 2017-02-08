//
//  HTTPSocketManager.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 12/01/2017.
//  Copyright © 2017 Nuvoton. All rights reserved.
//

import UIKit

@objc protocol HTTPSocketDelegate {
    func dataRead(data: Data)
    func didConnected()
    @objc optional func acceptSocket()
}
class HTTPSocketManager: NSObject, GCDAsyncSocketDelegate {
    let SOCKET_UPLOAD_AUDIO_STREAM = 60
    var isConnected = false
    var delegate: HTTPSocketDelegate?
    var socket: GCDAsyncSocket?
    var audioSocket: GCDAsyncSocket?
    var socketQueue: DispatchQueue?
    var audioSocketQueue: DispatchQueue?
    static let sharedInstance: HTTPSocketManager = {HTTPSocketManager()}() // lazy initialization closure
    
    private override init(){
        super.init()
        socketQueue = DispatchQueue.init(label: "HTTPSocketQueue")
        audioSocketQueue = DispatchQueue.init(label: "AudioSocketQueue")
        if socket == nil {
            socket = GCDAsyncSocket.init(delegate: self, delegateQueue: socketQueue)
        }
        if audioSocket == nil {
            audioSocket = GCDAsyncSocket.init(delegate: self, delegateQueue: audioSocketQueue)
        }
    }
    
    //MARK: GCDAsyncSocket Delegate
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        delegate?.didConnected()
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        delegate?.dataRead(data: data)
    }
    
    //MARK: utility
    func connect(host: String, port: Int) -> Void {
        do {
            print("host: \(host), port: \(port)")
            try socket?.connect(toHost: host, onPort: UInt16(port))
            isConnected = true
        } catch  {
            isConnected = false
        }
    }
    
    func write(data: Data) -> Void {
        if isConnected {
            socket?.write(data, withTimeout: -1, tag: 0)
        }
    }
    
    func sendMicAudio(data: NSData) -> Void {
        audioSocket?.write(data as Data, withTimeout: -1, tag: SOCKET_UPLOAD_AUDIO_STREAM)
    }
    
    func disconnectMicSocket() -> Void {
        audioSocket?.disconnect()
    }
    
    //MARK: Audio with Socket
    func waitSocketConnection() -> Void {
        do {
            try audioSocket?.accept(onPort: 8080)
        } catch _ {
            print("wait socket error")
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        audioSocket = newSocket
        delegate?.acceptSocket!()
    }
}
