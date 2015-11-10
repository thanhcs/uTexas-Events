//
//  Host.swift
//  project
//
//  Created by Thanh Nguyen on 11/3/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import Foundation
import CoreData


class Host: NSManagedObject {

    func addEvent(value: Event) {
        let items = self.mutableSetValueForKey("events")
        items.addObject(value)
    }
    
    func removeEvent(value: Event) {
        let items = self.mutableSetValueForKey("events")
        items.removeObject(value)
    }
}
