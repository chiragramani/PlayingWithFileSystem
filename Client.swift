//
//  Client.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import Foundation


final class DropboxClient: NSObject
{
    
    static let sharedInstance = DropboxClient()
    var access_token : String?=nil
    var uid : String?=nil
    var account_id : String?=nil
   
    
    override init() {
        super.init()
    }
    
    final func taskForPOSTMethod(parse:Bool,api:String,method:String,headers:[String:AnyObject]?,jsonBody:String?,completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
    {
       
    
    let request = NSMutableURLRequest(URL: URLFromParameters(api, parameters: nil, withPathExtension: method))
         request.HTTPMethod="POST"
        if let headers = headers
        { for (key,value) in headers
        {
            request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        request.addValue("Bearer \(DropboxClient.sharedInstance.access_token!)", forHTTPHeaderField: "Authorization")
         
       
        if let jsonBody = jsonBody
        {
            request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print("\(error)\n")
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
                
            }
            
            print((response as? NSHTTPURLResponse)?.statusCode)
            
            // GUARD: Was there an error?
           guard (error == nil) else {
                if(error!.code==(-1009))
                {
                    sendError("The Internet connection appears to be offline")
                }
                else
                {
                    sendError("There was an error with your request: \(error)")
                }
                return
            }
            
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if (response as? NSHTTPURLResponse)?.statusCode == 401
                {
                    sendError("Unauthorized!")
                }
                else
                {
                    sendError("Invalid Request!")
                }
                return
            }
            
 
            // GURAD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            if(parse)
            {
            // Parse the data and use it (in the compltetion handler).
            convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            }
            else
            {
            completionHandlerForPOST(result: data, error: nil)
            }
        }
        
        // Start the request
        task.resume()
        
        return task
    }

    
    
    
    
    
    
    
    }
    
  /*  func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: URLFromParameters(api, parameters: nil, withPathExtension: method))
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                if(error!.code==(-1009))
                {
                    sendError("The Internet connection appears to be offline")
                }
                else
                {
                    sendError("There was an error with your request: \(error)")
                }
                return
            }
            
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    */
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
           
            
        } catch {
            print("canot parse data")
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    // create a URL from parameters
private func URLFromParameters(api:String,parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = DropboxClient.Constants.APIScheme
        components.host = api
        components.path = DropboxClient.Constants.APIPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        
        if let parameters=parameters
        {
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        
        return components.URL!
    }




