//
//  newFileViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 03/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class newFileViewController: UIViewController,UITextViewDelegate,UIGestureRecognizerDelegate {
    
    
    @IBOutlet var fileSizeLabel: UILabel!
    
    @IBOutlet var fileContents: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden=true
        fileContents.delegate=self
        fileContents.textColor=UIColor.whiteColor()
        fileContents.font=UIFont(name: "HelveticaNeue-CondensedBlack", size: 16)
        let saveButton=UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(newFileViewController.saveFile))
        let scaleButton=UIBarButtonItem(title: "Scale", style: .Plain, target: self, action: #selector(newFileViewController.scaleToBytes))
        self.navigationItem.rightBarButtonItems=[saveButton,scaleButton]
        
        
        let tapTerm = UITapGestureRecognizer(target: self, action: #selector(newFileViewController.tapTextView))
        tapTerm.numberOfTapsRequired=2
        tapTerm.delegate = self
        view.addGestureRecognizer(tapTerm)
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
        self.fileSizeLabel.text="Size : \(formatter.stringFromByteCount(bytes))"
    }
    
    func tapTextView()
    {
    fileContents.resignFirstResponder()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
     func scaleToBytes()
    {
        let fileData=self.fileContents.text.dataUsingEncoding(NSUTF8StringEncoding)
        let fileSize=(fileData?.length)! as NSNumber
        if(fileSize==0)
        {
        let alertController = UIAlertController(title: "Enter", message: "Please enter some text for scaling", preferredStyle: .Alert)
        let dismissAction=UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        }
        else
        {
            let alertController = UIAlertController(title: "Scale to Bytes..", message: "Current Bytes \(fileSize) Maximum : 16MB (16777216)", preferredStyle: .Alert)
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.addTarget(self, action: #selector(newFileViewController.userEnteredScalingSize), forControlEvents: .EditingChanged)
                textField.placeholder = "File Size in bytes"
            }
            let fileTextField = alertController.textFields![0] as UITextField
            
            
           let cancelAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            let scaleAction=UIAlertAction(title: "Scale", style: .Default) { (UIAlertAction) in
                let enteredFileSize=fileTextField.text
                
                if let enteredFileSize = enteredFileSize {
                
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)){
                    self.scaleData(fileData!, scaleSize: Int(enteredFileSize)!)
                    }
                
                    
                    
                }
            }
            
            alertController.addAction(scaleAction)
            alertController.actions[1].enabled=false
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        }
    
    
    func userEnteredScalingSize(sender:AnyObject)
    {
        let fileData=self.fileContents.text.dataUsingEncoding(NSUTF8StringEncoding)
        let fileSize=(fileData?.length)! as NSNumber
        var flag:Bool=true
        let tf = sender as! UITextField
        var resp : UIResponder = tf
        while !(resp is UIAlertController) { resp = resp.nextResponder()! }
        let alert = resp as! UIAlertController
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        if let enteredFileSize=tf.text
        {
            if(enteredFileSize.isEmpty)
            {
            flag=false
            }
            else
            {
        for c in enteredFileSize.utf16
        {
           if(!digits.characterIsMember(c))
           {
            flag=false
            break
            }
                }
                if((Int(enteredFileSize) > 16777216))
                {
                tf.text=""
                flag=false
                }
                else if ((Int(enteredFileSize) <= fileSize.integerValue) || ((Int(enteredFileSize)! + fileSize.integerValue) >= 16777216))
                {
                flag=false
                }
                
            }
            alert.actions[1].enabled=flag
        }
        else
        {
            alert.actions[1].enabled=false
        }
    }
    
    
    
    func scaleData( dataString:NSData,scaleSize:Int)
    {
        
        
        let resultData=NSMutableData(data: dataString)
        while(resultData.length < scaleSize-resultData.length)
        {
            
            resultData.appendData(resultData)
            
        }
        if(resultData.length != scaleSize)
        {
        let difference = scaleSize-resultData.length
        resultData.increaseLengthBy(difference)
        }
         dispatch_async(dispatch_get_main_queue())
         {
            var fileName:NSString=""
            let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
            let stack=delegate.stack
            let stringData = NSString(data: dataString, encoding: NSUTF8StringEncoding)
            fileName=((stringData?.length)!>10 ? stringData?.substringToIndex(10) :  stringData)!
            File(fileCategory: nil, fileName: fileName as String, fileSize: resultData.length, fileType: "txt", fileData: resultData, context: stack.context)
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
