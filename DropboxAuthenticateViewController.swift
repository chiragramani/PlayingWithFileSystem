//
//  DropboxAuthenticateViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit
import CoreData

class DropboxAuthenticateViewController: UIViewController,UIWebViewDelegate {
    
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate=self
        let urlmodified=NSURL(string: "https://www.dropbox.com/1/oauth2/authorize?client_id=syu526a8tu8szjx&response_type=token&redirect_uri=https://www.google.com")
        let httprequest=NSURLRequest(URL: urlmodified!)
        webView.loadRequest(httprequest)
           }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        activityView.hidden=false
        activityView.startAnimating()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
       
        let requestString  = (request.URL?.absoluteString)
        print(requestString)
        if let requiredToken = ((requestString!.rangeOfString("access_token")))
        {
            var pathComponents = requestString!.componentsSeparatedByString("#")
            pathComponents.removeAtIndex(0)
            pathComponents=pathComponents[0].componentsSeparatedByString("&")
            DropboxClient.sharedInstance.access_token=pathComponents[0].componentsSeparatedByString("=")[1]
            DropboxClient.sharedInstance.uid=pathComponents[2].componentsSeparatedByString("=")[1]
            isUserNew(pathComponents[3].componentsSeparatedByString("=")[1])
            //DropboxClient.sharedInstance.account_id=pathComponents[3].componentsSeparatedByString("=")[1]
            //print(requiredToken)
            NSNotificationCenter.defaultCenter().postNotificationName("userAuthenticated", object: nil, userInfo: nil)
           
        }
        if let dismiss = (requestString!.rangeOfString("gfe_rd"))
        {
            self.navigationController?.popViewControllerAnimated(true)
            //print(dismiss)
        }
        
        if let dismiss = (requestString!.rangeOfString("browse"))
        {
            self.navigationController?.popViewControllerAnimated(true)
            
            //print(dismiss)
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityView.hidden=true
        activityView.stopAnimating()
    }
    
    func isUserNew(userId:String)
    {
        let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let stack=delegate.stack
        
    if let accountId = DropboxClient.sharedInstance.account_id
    {
       if !(userId == accountId)
       {
         DropboxClient.sharedInstance.account_id=userId
        dispatch_async(dispatch_get_main_queue())
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
        }
    
    }
    
}
}
