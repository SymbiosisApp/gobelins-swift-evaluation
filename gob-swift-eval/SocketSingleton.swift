//
//  SocketSingleton.swift
//  gob-swift-eval
//
//  Created by Etienne De Ladonchamps on 24/03/2016.
//  Copyright © 2016 Etienne De Ladonchamps. All rights reserved.
//

import Foundation
import SocketIOClientSwift


class Socket {
    
    static let sharedInstance = Socket()
    
    var io = SocketIOClient(socketURL: NSURL(string: "http://192.168.2.1:8000")!, options: [.Log(false), .ForcePolling(true)])
    
    init() {
        self.io.on("connect") {data, ack in
            print("socket connected")
        }
        
        self.io.connect()
    }
    
}