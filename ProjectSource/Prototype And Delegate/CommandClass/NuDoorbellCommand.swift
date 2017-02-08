//
//  NuDoorbellCommand.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 12/01/2017.
//  Copyright © 2017 Nuvoton. All rights reserved.
//

import UIKit

class NuDoorbellCommand: NSObject {
    static func setResolution(value: String) -> String {
        var command = "/server.command?command=set_resol&pipe=0&type=h264"
        command = command + "&value=" + value
        return command
    }
    
    static func setEncodeBitrate(value: String) -> String {
        var command = "/server.command?command=set_enc_bitrate&pipe=0&type=h264"
        command = command + "&value=" + value
        return command
    }
    
    static func startRecordPipe() -> String {
        let command = "/server.command?command=start_record_pipe&pipe=0&type=h264"
        return command
    }
    
    static func isPipeRecord() -> String {
        let command = "/server.command?command=is_pipe_record&pipe=0&type=h264"
        return command
    }
    
    static func stopRecordPipe() -> String {
        let command = "/server.command?command=stop_record&pipe=0&type=h264"
        return command
    }
    
    static func snapshot() -> String {
        let command = "/server.command?command=snapshot&pipe=0"
        return command
    }
    
    static func enableMute(isMute: Bool) -> String {
        var command = "/server.command?command=enable_mute&value="
        if isMute{
            command += "1"
        }else {
            command += "0"
        }
        return command
    }
    
    static func wifiSetup(apSsid: String, apPassword: String) -> String {
        var command = "/server.command?command=wifi_setup"
        command = command + "&ssid=" + apSsid + "&password=" + apPassword
        return command
    }
    
    static func restoreFactory() -> String {
        let command = "/server.command?command=restore_factory"
        return command
    }
    
    static func restart() -> String {
        let command = "/server.command?command=restart"
        return command
    }
}
