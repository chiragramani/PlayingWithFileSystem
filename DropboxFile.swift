//
//  DropboxFile.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import CoreData


class DropboxFile: NSManagedObject {

    convenience init (filePath:String,fileId:String,fileName:String,fileSize:NSNumber,fileType:String,context:NSManagedObjectContext)
    {
        if let entity=NSEntityDescription.entityForName("DropboxFile", inManagedObjectContext: context)
        {
            self.init(entity: entity,insertIntoManagedObjectContext: context)
            self.fileName=fileName
            self.fileId=fileId
            self.fileSize=fileSize
            self.fileType=fileType
            self.path=filePath
            
        }
        else
        {
            fatalError("Entity File does not exist")
        }
    }

}
