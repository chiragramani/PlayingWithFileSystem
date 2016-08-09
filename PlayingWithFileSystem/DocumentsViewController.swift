//
//  DocumentsViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 01/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        let fetchRequest = NSFetchRequest(entityName: "File")
        let sortDescriptor = NSSortDescriptor(key: "fileName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentsViewController.catchNotification1(_:)), name: "openURL", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentsViewController.catchNotification2(_:)), name: "fileAlreadyExists", object: nil)
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.hidden=false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func formatBytes(bytes:NSNumber)->String
    {
        let formatter = NSByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        formatter.includesActualByteCount=true
        let bytesLongValue=bytes.longLongValue
        return formatter.stringFromByteCount(bytesLongValue)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId") as! CustomTableViewCell
        let file=fetchedResultsController.objectAtIndexPath(indexPath) as! File
        cell.uploadLabel.hidden=true
        cell.fileNameLabel.text=file.fileName
        cell.fileNameLabel.numberOfLines=0
        cell.accessoryType=UITableViewCellAccessoryType.DetailDisclosureButton
        
        cell.fileSizeLabel.text=formatBytes(file.fileSize!)
        switch(file.fileType!)
        {
        case "doc","docx" : cell.myImageView.image=UIImage(named: "word")
            break
        case "pdf" : cell.myImageView.image=UIImage(named: "pdf")
            break
        case "xls","xlsx" : cell.myImageView.image=UIImage(named: "excel")
            break
        case "txt" : cell.myImageView.image=UIImage(named: "txt")
            break
        case "jpg" : cell.myImageView.image=UIImage(named: "jpg")
            break
        case "png" : cell.myImageView.image=UIImage(named: "png")
            break
        case "jpeg" : cell.myImageView.image=UIImage(named: "jpeg")
            break
            
        default : cell.myImageView.image=UIImage(named: "unknown")
            break
        }
        cell.layoutSubviews()
        return cell
    }
    
    
    
    
    func catchNotification1(notification:NSNotification) -> Void {
        print("Got notification")
        guard let userInfo = notification.userInfo,
            let fileName  = userInfo["fileName"] as? String
            else {
                print("No userInfo found in notification")
                return
        }
        let alert = UIAlertController(title: "Notification!",message:"\(fileName) added to Documents",preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func catchNotification2(notification:NSNotification) -> Void {
        print("Got notification")
        let alert = UIAlertController(title: "Notification!",message:"File Already Exists",preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                tableView.cellForRowAtIndexPath(indexPath)
            }
            break;
        default:
            break;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    @IBAction func moreBarItemPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil , message: nil, preferredStyle: .ActionSheet)
        
        let createNonDLPFileAction=UIAlertAction(title: "Create Custom-DLP File", style: .Default)
        { (UIAlertAction) in
            let newFileVC=self.storyboard?.instantiateViewControllerWithIdentifier("newFileVC") as! newFileViewController
            self.navigationController?.pushViewController(newFileVC, animated: true)
            
        }
        
        let sortFileAction=UIAlertAction(title: "Sort Files By...", style: .Default){ (UIAlertAction) in
            
            let alertController = UIAlertController(title: "Sort Files By..." , message: nil, preferredStyle: .ActionSheet)
            let sortByName=UIKit.UIAlertAction(title: "Name", style: .Default){ (UIAlertAction) in
                self.fetchedResultsController.fetchRequest.sortDescriptors?.removeAll()
                self.fetchedResultsController.fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "fileName", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:))))
                
                do {
                    try self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                } catch {
                    let fetchError = error as NSError
                    print("\(fetchError), \(fetchError.userInfo)")
                }
            }
            
            let sortBySize=UIKit.UIAlertAction(title: "Size", style: .Default){ (UIAlertAction) in
                
                self.fetchedResultsController.fetchRequest.sortDescriptors?.removeAll()
                self.fetchedResultsController.fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "fileSize", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:))))
                do {
                    try self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                } catch {
                    let fetchError = error as NSError
                    print("\(fetchError), \(fetchError.userInfo)")
                }
            }
            
            let sortByFileType=UIKit.UIAlertAction(title: "FileType", style: .Default){ (UIAlertAction) in
                
                self.fetchedResultsController.fetchRequest.sortDescriptors?.removeAll()
                self.fetchedResultsController.fetchRequest.sortDescriptors?.append(NSSortDescriptor(key: "fileType", ascending: true,selector: #selector(NSString.caseInsensitiveCompare(_:))))
                do {
                    try self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                } catch {
                    let fetchError = error as NSError
                    print("\(fetchError), \(fetchError.userInfo)")
                }
            }
            
            let cancelAction=UIKit.UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(sortByName)
            alertController.addAction(sortBySize)
            alertController.addAction(sortByFileType)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        let cancelAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let fetchImages=UIAlertAction(title: "Fetch Images", style: .Default) { (UIAlertAction) in
            let controller = UIImagePickerController()
            controller.delegate=self
            controller.allowsEditing=false
            let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
            if !(cameraAvailable)
            {   controller.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(controller, animated: true, completion: nil)
            }
            else
            {
                let alertController=UIAlertController(title: "Fetch Images From", message: nil, preferredStyle: .ActionSheet)
                let fromCameraAction=UIKit.UIAlertAction(title: "Camera", style: .Default, handler: { (UIAlertAction) in
                    controller.sourceType=UIImagePickerControllerSourceType.Camera
                    self.presentViewController(controller, animated: true, completion: nil)
                })
                
                let fromPhotoLibraryAction=UIKit.UIAlertAction(title: "Photo Library", style: .Default, handler: { (UIAlertAction) in
                    controller.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
                    self.presentViewController(controller, animated: true, completion: nil)
                })
                let cancelAction=UIKit.UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(fromCameraAction)
                alertController.addAction(fromPhotoLibraryAction)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(createNonDLPFileAction)
        alertController.addAction(sortFileAction)
        alertController.addAction(fetchImages)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let file=fetchedResultsController.objectAtIndexPath(indexPath) as! File
        let cell=tableView.cellForRowAtIndexPath(indexPath) as! CustomTableViewCell
        let alertController = UIAlertController(title: "\(file.fileName!)" , message: nil, preferredStyle: .ActionSheet)
        let previewAction=UIAlertAction(title: "Preview Document", style: .Default) { (UIAlertAction) in
            let fileVC=self.storyboard?.instantiateViewControllerWithIdentifier("fileViewController") as! FileViewController
            fileVC.file=file
            self.navigationController?.pushViewController(fileVC, animated: true)
            
        }
        let uploadFileAction=UIAlertAction(title: "Upload File to Dropbox", style: .Default) { (UIAlertAction) in
            
            
            if(DropboxClient.sharedInstance.access_token==nil)
            {
                let alertController = UIAlertController(title: "Authenticate" , message: "Please authenticate with Dropbox to uplaod files", preferredStyle: .Alert)
                let dismissAction=UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                alertController.addAction(dismissAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else
            {
                cell.uploadLabel.hidden=false
                DropboxClient.sharedInstance.uploadFile(file, completionHandler: { (success, errorString) in
                    dispatch_async(dispatch_get_main_queue())
                    {
                        if(success)
                        {
                            let alertController = UIAlertController(title: "\(file.fileName!) successfully uploaded" , message: nil, preferredStyle: .Alert)
                            let dismissAction=UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                            alertController.addAction(dismissAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            cell.uploadLabel.hidden=true
                            
                        }
                        else
                        {
                            let alertController = UIAlertController(title: "Error uploading \(file.fileName!) " , message: errorString!, preferredStyle: .Alert)
                            let dismissAction=UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                            alertController.addAction(dismissAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            cell.uploadLabel.hidden=true
                            
                        }
                    }
                })
            }
        }
        
        let dismissAction=UIKit.UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let deleteAction=UIAlertAction(title: "Delete", style: .Destructive) { (UIAlertAction) in
            
            let file=self.fetchedResultsController.objectAtIndexPath(indexPath) as! File
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let stack = delegate.stack
            stack.context.deleteObject(file)
            tableView.reloadData()
            let alert = UIAlertController(title: "Notification!",message:"File \(file.fileName!) deleted",preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIKit.UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            do
            {       try stack.saveContext()
            }catch
            {
                print("Error saving context")
            }
            
        }
        alertController.addAction(deleteAction)
        alertController.addAction(previewAction)
        alertController.addAction(uploadFileAction)
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let imageData=UIImageJPEGRepresentation(image, CGFloat(1.0))
        let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let stack=delegate.stack
        let alertController=UIAlertController(title: "Save image as..", message: nil, preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "File Name"
        }
        let cancelAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction=UIAlertAction(title: "Save", style: .Default) { (UIAlertAction) in
            
            let textFieldFileName=alertController.textFields![0] 
            let fileName=textFieldFileName.text
            if let fileName=fileName
            {
                if(fileName.isEmpty)
                {
                    File(fileCategory: nil, fileName: "Untitled.jpeg", fileSize: imageData!.length, fileType: "jpeg", fileData: imageData!, context: stack.context)
                    var urlInfo=[String:AnyObject]()
                    urlInfo["fileName"]="Untitled.jpeg"
                    NSNotificationCenter.defaultCenter().postNotificationName("openURL", object: nil, userInfo: urlInfo)
                }
                else
                {
                    File(fileCategory: nil, fileName: "\(fileName).jpeg", fileSize: imageData!.length, fileType: "jpeg", fileData: imageData!, context: stack.context)
                    var urlInfo=[String:AnyObject]()
                    urlInfo["fileName"]="\(fileName).jpeg"
                    NSNotificationCenter.defaultCenter().postNotificationName("openURL", object: nil, userInfo: urlInfo)
                }
                
            }
            else
            {
                File(fileCategory: nil, fileName: "Untitled.jpeg", fileSize: imageData!.length, fileType: "jpeg", fileData: imageData!, context: stack.context)
                var urlInfo=[String:AnyObject]()
                urlInfo["fileName"]="Untitled.jpeg"
                NSNotificationCenter.defaultCenter().postNotificationName("openURL", object: nil, userInfo: urlInfo)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "openURL", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "fileAlreadyExists", object: nil)
    }
    
}
