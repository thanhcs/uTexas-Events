//
//  Config.swift
//  project
//
//  Created by Thanh Nguyen on 11/22/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import Foundation
import Parse

class Config {
    static var didLogIn = false
    static var isAdmin = false
    
    static var RSVPList:[String]? = nil
    
    class func addEventToRSVPList(eventID eventID:String) {
        RSVPList?.append(eventID)
        
        let user:PFUser = PFUser.currentUser()!
        user["eventRSVPs"] = RSVPList
        user.saveInBackground()
    }
    
    class func delEventToRSVPList(eventID eventID:String) {
        RSVPList = RSVPList?.filter() {$0 != eventID}
        let user:PFUser = PFUser.currentUser()!
        user["eventRSVPs"] = RSVPList
        user.saveInBackground()
    }
}
