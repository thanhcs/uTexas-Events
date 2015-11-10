//
//  Host+CoreDataProperties.swift
//  project
//
//  Created by Thanh Nguyen on 11/3/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Host {

    @NSManaged var name: String?
    @NSManaged var info: String?
    @NSManaged var email: String?
    @NSManaged var events: NSSet?
    


}
