//
//  NuWicamCommand.swift
//  NuDoorbell
//
//  Created by CCHSU20 on 12/01/2017.
//  Copyright © 2017 Nuvoton. All rights reserved.
//

import UIKit

class NuWicamCommand: NSObject {
    static func listWifiParamters() -> String {
        let command = "/param.cgi?action=list&group=wifi"
        return command
    }
    
    static func updateWifiParameters(apSsid: String, apPassword: String) -> String {
        var command = "/param.cgi?action=update&group=wifi"
        command = command + "&AP_SSID=" + apSsid + "&AP_AUTH_KEY=" + apPassword
        return command
    }
    
    static func listStreamParameters() -> String {
        let command = "/param.cgi?action=list&group=stream"
        return command
    }
    /*
         VINWIDTH
            8~4096
         VINHEIGHT
            8~4096
         JPEGENCWIDTH
            8~4096
         JPEGENCHEIGHT
            8~4096
         BITRATE
            1024~8192
    */
    static func updateStreamParameters(parameters: [String: String]) -> String {
        var command = "/param.cgi?action=update&group=stream"
        for key in parameters.keys {
            let value = parameters[key]
            command = command + "&" + key + "=" + value!
        }
        return command
    }
    
    /*
     wifi
          Restart Wi-Fi start-up procedure.
     board
          Reset board.
     stream
          Restart stream
     */
    static func restart(category: String) -> String {
        let command = "/restart.cgi?group=" + category
        return command
    }
}
