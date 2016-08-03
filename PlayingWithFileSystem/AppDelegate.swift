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
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
       
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        do
        {       try stack.saveContext()
        }catch
        {
            print("Error saving context")
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
            //print("\(fetchError), \(fetchError.userInfo)")
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


