//
//  newFileViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 03/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class newFileViewController: UIViewController,UITextViewDelegate {
    
    
    @IBOutlet var fileSizeLabel: UILabel!
    
    @IBOutlet var fileContents: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden=true
        fileContents.delegate=self
        fileContents.textColor=UIColor.whiteColor()
        fileContents.font=UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(newFileViewController.saveFile))
    }
    
    func saveFile()
    {
        let alertController = UIAlertController(title: "Save File As.", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "File Name"
        }
        let fileTextField = alertController.textFields![0] as UITextField
        let cancelAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction=UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) in
            let fileName=fileTextField.text
            if let fileName = fileName
            {
                if(fileName.isEmpty)
                {
                    let alertController = UIAlertController(title: "Please enter filename", message: nil, preferredStyle: .Alert)
                    let cancelAction=UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else
                {
                    let fileData=self.fileContents.text.dataUsingEncoding(NSUTF8StringEncoding)
                    let fileSize=(fileData?.length)! as NSNumber
                    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let stack = delegate.stack
                    File(fileCategory: nil, fileName: fileName, fileSize: fileSize, fileType: "txt", fileData: fileData!, context: stack.context)
                    var urlInfo=[NSObject:AnyObject]()
                    urlInfo["fileName"] = fileName
                    do
                    {       try stack.saveContext()
                    }catch
                    {
                        print("Error saving context")
                    }
                    self.navigationController?.popViewControllerAnimated(true)
                    NSNotificationCenter.defaultCenter().postNotificationName("openURL", object: nil, userInfo: urlInfo)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if(textView.text == "Enter text")
        {
            textView.text=""
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        let fileData=self.fileContents.text.dataUsingEncoding(NSUTF8StringEncoding)
        let fileSize=(fileData?.length)! as NSNumber
        
        let formatter = NSByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        formatter.countStyle=NSByteCountFormatterCountStyle.Memory
        let bytes=fileSize.longLongValue
        self.fileSizeLabel.text=formatter.stringFromByteCount(bytes)
    }
}
