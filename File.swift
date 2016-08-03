//
//  File.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 02/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import CoreData


class File: NSManagedObject {

    convenience init (fileCategory:String?,fileName:String,fileSize:NSNumber,fileType:String,fileData:NSData,context:NSManagedObjectContext)
    {
        if let entity=NSEntityDescription.entityForName("File", inManagedObjectContext: context)
        {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.fileName=fileName
            self.fileSize=fileSize
            self.fileType=fileType
            self.fileData=fileData
            if let fileCat = fileCategory
            {
                self.fileCategory=fileCat
            }
        }
        else
        {
            fatalError("Entity File does not exist")
        }
    }

}
