//
//  Convenience.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension DropboxClient
{
    
    func fetchFolderContents(completionHandler:(success: Bool, errorString: String?) -> Void)
    {
        var headers=[String:AnyObject]()
        
        let method = DropboxClient.Methods.ListFolderContents
        let api=DropboxClient.Constants.APIHost2
        headers["Content-Type"] = "application/json"
        let jsonBody="{\"\(DropboxClient.JSONRequestKeys.Path)\": \"\"}"
        DropboxClient.sharedInstance.taskForPOSTMethod(true, api: api, method: method, headers: headers, jsonBody: jsonBody)
       { (result, error) in
            
            if let error=error
            {
                print(error)
                completionHandler(success: false,errorString: error.localizedDescription)
            }
            else
            {
                guard let results=result as? [String:AnyObject] else
                {
                    completionHandler(success: false, errorString: "Invalid Response..Try Again")
                    return
                }
                
                guard let entries = results[DropboxClient.JSONResponseKeys.Entries] as? [[String:AnyObject]] else
                {
                    completionHandler(success: false, errorString: "Invalid Response..Try Again")
                    return
                    
                }
                let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
                let stack=delegate.stack
                
                
                /*    dispatch_async(dispatch_get_main_queue())
                 {
                 let fetchRequest = NSFetchRequest(entityName: "DropboxFile")
                 fetchRequest.sortDescriptors=[NSSortDescriptor(key: "fileName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
                 ]
                 let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                 do {
                 try stack.context.persistentStoreCoordinator?.executeRequest(deleteRequest, withContext: stack.context)
                 } catch let error as NSError {
                 print(error)
                 }
                 do
                 {       try stack.saveContext()
                 }catch
                 {
                 print("Error saving context")
                 }
                 
                 }
                 */
                var coreDataEntries:[DropboxFile]?
                let fetchRequest=NSFetchRequest(entityName: "DropboxFile")
                
                
                do {
                    coreDataEntries = try stack.context.executeFetchRequest(fetchRequest) as? [DropboxFile]
                    
                } catch let error as NSError {
                    
                    print("Fetch failed: \(error.localizedDescription)")
                }
                var fileObjectId=[String]()
                
                
                if let coreDataEntries = coreDataEntries
                {
                    for dropboxFile in coreDataEntries
                    {
                        fileObjectId.append(dropboxFile.fileId!)
                        
                    }
                }
                print(fileObjectId)
                
                
                for entry in entries{
                    
                    let fileName=entry[DropboxClient.JSONResponseKeys.Name] as! String
                    let fileId=entry[DropboxClient.JSONResponseKeys.Id] as! String
                    let filePath=entry[DropboxClient.JSONResponseKeys.Path] as! String
                    let fileSize=Int(entry[DropboxClient.JSONResponseKeys.Size] as! Int)
                    let fileType=fileName.componentsSeparatedByString(".")
                    
                    if (fileObjectId.count != 0)
                    {
                        
                        if !(fileObjectId.contains(fileId))
                        {
                            
                            DropboxFile(filePath: filePath, fileId: fileId, fileName: fileName, fileSize: fileSize, fileType: fileType[fileType.count-1], context: stack.context)
                        }
                        
                    }
                    else
                    {
                        DropboxFile(filePath: filePath, fileId: fileId, fileName: fileName, fileSize: fileSize, fileType: fileType[fileType.count-1], context: stack.context)
                    }
                    
                }
                completionHandler(success: true, errorString: nil)
                
                
            }
            
        }
        
    }
    
    func downloadFile(dropboxFile:DropboxFile,completionHandler:(success: Bool, errorString: String?) -> Void)
    {
        var headers=[String:AnyObject]()
        let method = DropboxClient.Methods.FileDownload
        let api=DropboxClient.Constants.APIHost1
        let headerValue="{\"\(DropboxClient.JSONRequestKeys.Path)\": \"\(dropboxFile.path!)\"}"
         headers["Dropbox-API-Arg"]=headerValue
        let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let stack=delegate.stack
       
        DropboxClient.sharedInstance.taskForPOSTMethod(false, api: api, method: method, headers: headers, jsonBody: nil)
       { (result, error) in
            if error == nil
            {
            dispatch_async(dispatch_get_main_queue())
            {
                    dropboxFile.fileData=result as? NSData
                do
                {       try stack.saveContext()
                }catch
                {
                    print("Error saving context")
                }
            }
            completionHandler(success: true, errorString: nil)
            }
        else
            {
        
        completionHandler(success: false  , errorString: error?.localizedDescription)
        }
            
            
        }
    }
}



