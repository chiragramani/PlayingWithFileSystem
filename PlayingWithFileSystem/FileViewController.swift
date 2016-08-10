//
//  FileViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 31/07/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class FileViewController: UIViewController,UIWebViewDelegate {
    
    var file:File?
    var dropboxFile:DropboxFile?
    var fileUTI:String?
    
    @IBOutlet var activityView: UIActivityIndicatorView!
    
    lazy private var documentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureActivityView(false)
        loadWebView()
        webView.delegate=self
        webView.backgroundColor=UIColor.clearColor()
        webView.opaque=false
        self.tabBarController?.tabBar.hidden=true
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(FileViewController.shareFile))
        
    }
    
    func loadWebView()
    {
        
        var mimeType:String?
        let fileType=(file==nil) ? dropboxFile!.fileType! : file!.fileType!
        
        switch(fileType)
        {
        case "pdf":  mimeType = "application/pdf"
        fileUTI="com.adobe.pdf"
            break
        case "docx":  mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        fileUTI="org.openxmlformats.wordprocessingml.document"
            break
            
        case "doc":  mimeType = "application/msword"
        fileUTI="org.openxmlformats.wordprocessingml.document"
            break
            
        case "xls":  mimeType = "application/vnd.ms-excel"
        fileUTI="org.openxmlformats.wordprocessingml.document"
            break
            
        case "xlsx ":  mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        fileUTI="org.openxmlformats.wordprocessingml.document"
            break
            
        case "ppt":  mimeType = "application/vnd.ms-powerpoint"
        fileUTI="org.openxmlformats.wordprocessingml.document"
            break
            
        case "pptx":  mimeType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        fileUTI="org.openxmlformats.wordprocessingml.document"
            break
            
        case "txt":  mimeType = "text/plain"
        fileUTI="public.utf8-plain-text"
            break
            
        case "jpg":  mimeType = "image/jpg"
        fileUTI="public.jpeg"
            break
            
        case "jpeg":  mimeType = "image/jpeg"
        fileUTI="public.jpeg"
            break
            
        case "png":  mimeType = "image/png"
        fileUTI="public.png"
            break
            
        default :
            break
        }
        
        if let mime=mimeType
        {
            if(dropboxFile==nil)
            {
                webView.loadData((file?.fileData)!, MIMEType: mime, textEncodingName: "UTF-8", baseURL: NSURL())
            }
            else
            {
                webView.loadData((dropboxFile?.fileData)!, MIMEType: mime, textEncodingName: "UTF-8", baseURL: NSURL())
            }
        }
        else
        {   configureActivityView(true)
            let alert = UIAlertController(title: "Oops!",message:"File Type not supported for viewing",preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func shareFile()
    {
        let temporaryDirectory = NSTemporaryDirectory() as NSString
        let fileName = (dropboxFile==nil) ? file!.fileName! : dropboxFile!.fileName!
        let temporaryFilePath = temporaryDirectory.stringByAppendingPathComponent(fileName)
        let boolValue = (dropboxFile==nil) ? file!.fileData!.writeToFile(temporaryFilePath, atomically: true) : dropboxFile?.fileData?.writeToFile(temporaryFilePath, atomically: true)
        if((boolValue?.boolValue) == true)
        {
            documentInteractionController.URL = NSURL.fileURLWithPath(temporaryFilePath)
            documentInteractionController.UTI = fileUTI!
            self.documentInteractionController.presentOpenInMenuFromRect(
                view.bounds,
                inView: view,
                animated: true
            )}
        else
        {
            let alert = UIAlertController(title: "Oops!",message:"File Type not supported for sharing",preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        configureActivityView(true)
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
}
