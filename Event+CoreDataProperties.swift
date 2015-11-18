//
//  Event+CoreDataProperties.swift
//  project
//
//  Created by Thanh Nguyen on 11/4/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Event {

    @NSManaged var capacity: NSNumber?
    @NSManaged var date: String?
    @NSManaged var desc: String?
    @NSManaged var location: String?
    @NSManaged var title: String?
    @NSManaged var from: String?
    @NSManaged var to: String?
    @NSManaged var eventID: String?
    @NSManaged var category: Category?
    @NSManaged var host: Host?

}
