//
//  FileViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 31/07/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class FileViewController: UIViewController {
    
    var file:File?
    var fileUTI:String?
    lazy private var documentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden=true
        loadWebView()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(FileViewController.shareFile))

    }
    
    func loadWebView()
    {
        var mimeType:String?
        let fileType=file!.fileType!
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
        
        default :
        break
        }
        if let mime=mimeType
        {
        webView.loadData((file?.fileData)!, MIMEType: mime, textEncodingName: "UTF-8", baseURL: NSURL())
        }
        else
        {
            let alert = UIAlertController(title: "Oops!",message:"File Type not supported for viewing",preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func shareFile()
    {
        let temporaryDirectory = NSTemporaryDirectory() as NSString
        let fileName=file?.fileName
        let temporaryFilePath = temporaryDirectory.stringByAppendingPathComponent(fileName!)
        let boolValue = file?.fileData?.writeToFile(temporaryFilePath, atomically: true)
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
            let alert = UIAlertController(title: "OOps!",message:"File Type not supported for sharing",preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
}