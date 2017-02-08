//
//  NuPlayerCommand.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 12/01/2017.
//  Copyright © 2017 Nuvoton. All rights reserved.
//

import UIKit

class NuPlayerCommand: NSObject {
    static func setResolution(type: String, value: Int, width: Int, height: Int) -> String {
        var command = "/server.command?command=set_resol&pipe=0"
        command = command + "&type=" + type
        command = command + "&value=" + String(value)
        command = command + "&width=" + String(width)
        command = command + "&height=" + String(height)
        return command
    }
    
    static func setResolution(type: String, value: Int) -> String {
        var command = "/server.command?command=set_resol&pipe=0"
        command = command + "&type=" + type
        command = command + "&value=" + String(value)
        return command
    }
    
    static func getResolution(type: String) -> String {
        var command = "/server.command?command=get_resol&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func setEncodeQuality(type: String) -> String {
        var command = "/server.command?command=get_resol&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func getEncodeQuality(type: String) -> String {
        var command = "/server.command?command=get_enc_quality&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func setEncodeBitrate(type: String, value: Int) -> String {
        var command = "/server.command?command=set_enc_bitrate&pipe=0"
        command = command + "&type=" + type
        command = command + "&value=" + String(value)
        return command
    }
    
    static func getEncodeBitrate(type: String) -> String {
        var command = "/server.command?command=get_enc_bitrate&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func setFps(type: String, value: Int) -> String {
        var command = "/server.command?command=set_max_fps&pipe=0"
        command = command + "&type=" + type
        command = command + "&value=" + String(value)
        return command
    }
    
    static func getFps(type: String) -> String {
        var command = "/server.command?command=get_max_fps&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func mute(isMute: Bool) -> String {
        var command = "/server.command?command=enable_mute"
        if (isMute){
            command += "&value=1"
        }else {
            command += "&value=0"
        }
        return command
    }
    
    static func uploadAudioSocket(port: String) -> String {
        var command = "GET /audio.input?protocol=tcp&samplerate=8000&channel=1&volume=1&port="
        command = command + port
        command = command + " HTTP/1.1\r\n\r\n"
        return command
    }
    
    static func checkStorage() -> String {
        let command = "/GetStorageCapacity.ncgi"
        return command
    }
    
    static func snapshot() -> String {
        let command = "/server.command?command=snapshot&pipe=0"
        return command
    }
    
    static func recorderStatus(type: String) -> String {
        var command = "/server.command?command=is_pipe_record&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func startRecorder(type: String) -> String {
        var command = "/server.command?command=start_record_pipe&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func stopRecorder(type: String) -> String {
        var command = "/server.command?command=stop_record_pipe&pipe=0"
        command = command + "&type=" + type
        return command
    }
    
    static func listWifiParameters() -> String {
        let command = "/param.cgi?action=list&group=wifi"
        return command
    }
    
    static func updateWifiParameters(apSsid: String, apPassword: String) -> String {
        var command = "/param.cgi?action=update&group=wifi"
        command = command + "&AP_SSID=" + apSsid + "&AP_AUTH_KEY=" + apPassword
        return command
    }
    
    static func updatePluginParameters(paramters: Array<[String: String]>) -> String {
        var command = "/param.cgi?action=update&group=plugin"
        for parameter in paramters {
            let name = parameter["name"]
            command = command + "&name=" + name!
            let param = parameter["param"]
            command = command + " &param=" + param!
            let value = parameter["value"]
            command = command + "&value=" + value!
        }
        return command
    }
    
    static func listFile() -> String {
        let command = "/param.cgi?action=list&group=file"
        return command
    }
    
    static func reboot() -> String {
        let command = "/restart.cgi"
        return command
    }
    
    static func firmwareUpdate() -> String {
        let command = "/firmwareupgrade.cgi"
        return command
    }
}
