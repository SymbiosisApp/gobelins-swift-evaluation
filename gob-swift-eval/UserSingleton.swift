//
//  UserSingleton.swift
//  RemoteControl
//
//  Created by Quentin Tshaimanga on 18/05/2016.
//  Copyright © 2016 Etienne De Ladonchamps. All rights reserved.
//

import Foundation

//Persist User Data
class UserSingleton {
    static let sharedInstance = UserSingleton()
    
    //let defaults:NSUserDefaults;
    let defaults = NSUserDefaults.standardUserDefaults();
    var data:[String:AnyObject] = [:];
    
    private init() {
        print(self.data);
    }
    
    func getUserData() ->NSDictionary {
        
        if(defaults.dictionaryForKey("DATA") != nil){
            self.data = defaults.dictionaryForKey("DATA")!;
        }
        
        return self.data
    }
    
    func setUserParent(parent: Int) {
        self.defaults.setObject(parent, forKey: "parent")
    }
    
    func setUserData(id: Int, pseudo: String, date:String, email:String, mdp:String) {
        self.data = [
            "userId": id,
            "userPseudo":pseudo,
            "userDate":date,
            "userEmail":email,
            "userMdp":mdp
        ]
        self.defaults.setObject(self.data, forKey: "DATA")
        self.defaults.synchronize()
    }
    
}
