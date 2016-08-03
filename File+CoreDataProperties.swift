//
//  File+CoreDataProperties.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 02/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension File {

    @NSManaged var fileCategory: String?
    @NSManaged var fileName: String?
    @NSManaged var fileSize: NSNumber?
    @NSManaged var fileType: String?
    @NSManaged var fileData: NSData?

}
