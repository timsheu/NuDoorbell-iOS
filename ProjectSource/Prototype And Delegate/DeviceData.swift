//
//  DeviceData.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 22/12/2016.
//  Copyright © 2016 Nuvoton. All rights reserved.
//

// usage: http://sharkorm.com/guides
// writing objects:
/*
 Create a new object
    var thisDevice = DeviceData()
 Set some properties
    thisDevice.serial = 1
    thisDevice.deviceType = "NuDoorbell"
 Persist the object into the datastore
    thisDevice.commit()
 */

import UIKit

class DeviceData: SRKObject {
    dynamic var serial: Int = 0                 // Serial number of the device
    dynamic var deviceType: String?             // NuDoorbell, SkyEye, NuWiCam
    dynamic var publicIP: String?               // public ip of the device
    dynamic var privateIP: String?              // private ip of the device
    dynamic var httpPort: Int = 80              // http port of the device
    dynamic var rtspPort: Int = 554             // rtsp port of the device
    dynamic var fcmToken: String?               // Token was sent from Fire Base Messaging server
    dynamic var isVoiceUploadHttp: Bool = false // True: HTTP, false: tcp socket
    dynamic var isAdaptive: Bool = false        // True: In adaptive mode, false: not in adaptive mode
    dynamic var isFixedQuality: Bool = false    // True: In fixed quality mode, false: not in fixed quality mode
    dynamic var isFixedBitrate: Bool = false    // True: In fixed bit rate mode, false: not in fixed bitrate mode
    dynamic var isTCPTransmission: Bool = true  // True: RTSP with TCP, false: RTSP with UDP
    dynamic var isMute: Bool = true             // True: device is muted, false: device is not muted
    dynamic var isStorageAvailable: Bool = true // True: device has storage, false: device has not enough storage
    dynamic var isRecorderOn: Bool = false      // True: device recorder is on, false: device recorder is off
    dynamic var resolution: String?             // Device resolution: QVGA, VGA, 360p, 720p
    dynamic var encodeQulaity: Int = 30         // Device encode quality, range: 1-52
    dynamic var bitRate: Int = 1000             // Device bit rate, range: 1000-8000
    dynamic var fps: Int = 20                   // Device frame rate per second: 1-30
    dynamic var ssid: String?                   // Device SSID in soft AP mode
    dynamic var password: String?               // Device password in soft AP mode
    dynamic var history1: String?               // Device history list
    dynamic var history2: String?               // Device history list
    dynamic var history3: String?               // Device history list
    dynamic var history4: String?               // Device history list
    dynamic var history5: String?               // Device history list
    
}
