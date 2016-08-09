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
        let urlmodified=URLFromParameters()
        let httprequest=NSURLRequest(URL: urlmodified)
        webView.loadRequest(httprequest)
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(DropboxAuthenticateViewController.refreshWebView))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        configureActivityView(false)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        configureActivityView(false)
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
            NSNotificationCenter.defaultCenter().postNotificationName("userAuthenticated", object: nil, userInfo: nil)
            
        }
        if let dismiss = (requestString!.rangeOfString("gfe_rd"))
        {
            self.navigationController?.popViewControllerAnimated(true)
            print(dismiss)
        }
        
        if let dismiss = (requestString!.rangeOfString("browse"))
        {
            self.navigationController?.popViewControllerAnimated(true)
            
            print(dismiss)
        }
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        configureActivityView(true)
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
    
    func configureActivityView(bool:Bool)
    {
        activityView.hidden = bool ? true : false
        if(bool)
        {
            activityView.stopAnimating()
        }
        else
        {
            activityView.startAnimating()
        }
    }
    
    private func URLFromParameters() -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = DropboxClient.Constants.APIScheme
        components.host = DropboxClient.Constants.APIHost3
        components.path = DropboxClient.Constants.APIPath1 + ((DropboxClient.Methods.Authorize) ?? "")
        components.queryItems = [NSURLQueryItem]()
        var parameters:[String:AnyObject]?
        parameters=[DropboxClient.DropboxParameterKeys.ClientId : DropboxClient.DropboxParameterValues.ClientID,
                    DropboxClient.DropboxParameterKeys.ResponseType : DropboxClient.DropboxParameterValues.ResponseType,
                    DropboxClient.DropboxParameterKeys.RedirectURI : DropboxClient.DropboxParameterValues.RedirectURI]
        
        if let parameters=parameters
        {
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        
        return components.URL!
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
       if(error?.code == -1009)
       {
        configureActivityView(true)
        let alertController=UIAlertController(title: "Error", message: "No Internet Connectivity found", preferredStyle: .Alert)
        let dismissAction=UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        presentViewController(alertController, animated: true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func refreshWebView()
    {
        let urlmodified=URLFromParameters()
        let httprequest=NSURLRequest(URL: urlmodified)
        webView.loadRequest(httprequest)
       }

}
