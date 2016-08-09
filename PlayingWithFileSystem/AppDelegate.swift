//
//  AppDelegate.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 30/07/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
       let access_token = NSUserDefaults.standardUserDefaults().objectForKey("access_token")
       if let accesstoken=access_token as? String
       {
        DropboxClient.sharedInstance.access_token = accesstoken
        }
        else
       {
        DropboxClient.sharedInstance.access_token=nil
        }
        return true
    }
    
        func applicationDidEnterBackground(application: UIApplication) {
        do
        {       try stack.saveContext()
        }catch
        {
            print("Error saving context")
        }
    }
    
       func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let documentsDirectoryPath=NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        print(documentsDirectoryPath)
        let destinationPath = NSURL(fileURLWithPath: String(documentsDirectoryPath)).URLByAppendingPathComponent(url.lastPathComponent!)
        print(destinationPath)
        var urlInfo=[NSObject:AnyObject]()
        
        do{
            try NSFileManager.defaultManager().moveItemAtURL(url, toURL: destinationPath)
        } catch
        {
            let fetchError = error as NSError
            if(fetchError.code == 516)
            {
                NSNotificationCenter.defaultCenter().postNotificationName("fileAlreadyExists", object: application, userInfo: nil)
            }
                       return false
        }
        urlInfo["fileName"]=String(url.lastPathComponent!)
        saveFile(destinationPath)
        NSNotificationCenter.defaultCenter().postNotificationName("openURL", object: application, userInfo: urlInfo)
        return true
    }
    func saveFile(url:NSURL)->Void
    {   
        let lastPathComponent=url.lastPathComponent
        let urlComponents = lastPathComponent?.componentsSeparatedByString(".")
        let fileData=NSData(contentsOfURL: url)
    
        let fileSize=(fileData?.length)! as NSNumber
        print(urlComponents)
        
        File(fileCategory: nil, fileName: String(lastPathComponent!), fileSize: fileSize, fileType: urlComponents![(urlComponents?.count)!-1], fileData: fileData!, context: stack.context)
       
        try! NSFileManager.defaultManager().removeItemAtURL(url)
        do
        {       try stack.saveContext()
        }catch
        {
            print("Error saving context")
        }
    }
}


