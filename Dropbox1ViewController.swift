//
//  Dropbox1ViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 07/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit
import CoreData

class Dropbox1ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet var activityView: UIActivityIndicatorView!
    @IBOutlet var authenticateButton: UIButton!
    @IBOutlet var dropboxLogo: UIImageView!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureActivityView(true)
        tableView.delegate=self
        tableView.dataSource=self
        configureAuthenticateButton()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Dropbox1ViewController.userAuthenticated), name: "userAuthenticated", object: nil)
        performFetch()
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(Dropbox1ViewController.rightBarButtonItem))
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.hidden=false
        configureUI()
    }
    
    func configureUI()
    {
        let access_token = (DropboxClient.sharedInstance.access_token)
        tableView.hidden = (access_token==nil) ? true : false
        authenticateButton.hidden = (access_token==nil) ? false : true
        dropboxLogo.alpha = (access_token==nil) ? CGFloat(1.0) : CGFloat(0.5)
        self.navigationItem.rightBarButtonItem?.enabled = (access_token==nil) ? false  : true
        if (access_token != nil)
        {
            performFetch()
        }
    }
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        let fetchRequest = NSFetchRequest(entityName: "DropboxFile")
        let sortDescriptor = NSSortDescriptor(key: "fileName", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    @IBAction func authenticateButtonPressed(sender: AnyObject) {
        
        let dropboxVC=storyboard?.instantiateViewControllerWithIdentifier("dropboxAuthenticateVC") as! DropboxAuthenticateViewController
        self.navigationController?.pushViewController(dropboxVC, animated: true)
    }
    
    func configureAuthenticateButton()
    {
        authenticateButton.layer.cornerRadius = 5
        authenticateButton.layer.borderWidth = 1
        authenticateButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
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
        
        let cell=tableView.dequeueReusableCellWithIdentifier("CellId") as! Custom1TableViewCell
        let dropboxFile=fetchedResultsController.objectAtIndexPath(indexPath) as! DropboxFile
        cell.downloadLabel.hidden=true
        cell.fileNameLabel.text=dropboxFile.fileName
        cell.fileNameLabel.numberOfLines=0
        cell.fileSizeLabel.text=formatBytes(dropboxFile.fileSize!)
        cell.accessoryType=UITableViewCellAccessoryType.DetailDisclosureButton
        switch(dropboxFile.fileType!)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
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
            break
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break
        case .Update:
            if let indexPath = indexPath {
                tableView.cellForRowAtIndexPath(indexPath)
            }
            break
        default:
            break
        }
    }
    func performFetch()
    {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
    }
    
    func userAuthenticated()
    {
        NSUserDefaults.standardUserDefaults().setObject(DropboxClient.sharedInstance.access_token!, forKey: "access_token")
        listFolderContents()
    }
    
    func listFolderContents()
    {
        
        activityView.hidden=false
        activityView.startAnimating()
        DropboxClient.sharedInstance.fetchFolderContents { (success, errorString) in
            
            dispatch_async(dispatch_get_main_queue())
            {
                if(success)
                {
                    self.tableView.reloadData()
                    self.configureActivityView(true)
                    
                    let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
                    let stack=delegate.stack
                    do
                    {       try stack.saveContext()
                    }catch
                    {
                        print("Error saving context")
                    }
                }
                else
                {
                    self.configureActivityView(true)
                    let alertController=UIAlertController(title: "Error", message: errorString!, preferredStyle: .Alert)
                    let dismissAction=UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alertController.addAction(dismissAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }}
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    func configureActivityView(bool:Bool)
    {
        self.activityView.hidden = bool ? true : false
        if(bool)
        {
            self.activityView.stopAnimating()
        }
        else
        {
            self.activityView.startAnimating()
        }
    }
    
    func rightBarButtonItem()
    {
        let alertController=UIAlertController(title: "Dropbox", message: nil, preferredStyle: .ActionSheet)
        let refreshAction=UIAlertAction(title: "Refresh", style: .Default) { (UIAlertAction) in
            self.listFolderContents()
        }
        let logoutFromDropbox=UIAlertAction(title: "Logout from Dropbox", style: .Default) { (UIAlertAction) in
            DropboxClient.sharedInstance.access_token=nil
            DropboxClient.sharedInstance.account_id=nil
            DropboxClient.sharedInstance.uid=nil
            self.configureUI()
            
        }
        let cancelAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(refreshAction)
        alertController.addAction(logoutFromDropbox)
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let dropboxFile=fetchedResultsController.objectAtIndexPath(indexPath) as! DropboxFile
        let cell=tableView.cellForRowAtIndexPath(indexPath) as! Custom1TableViewCell
        let alertController=UIAlertController(title: "\(dropboxFile.fileName!)", message: nil, preferredStyle: .ActionSheet)
        let downloadFileAction=UIAlertAction(title: "Download File", style: .Default) { (UIAlertAction) in
            
            cell.downloadLabel.hidden=false
            let dropboxFile = self.fetchedResultsController.objectAtIndexPath(indexPath) as! DropboxFile
            if dropboxFile.fileData == nil
            {
                DropboxClient.sharedInstance.downloadFile(dropboxFile) { (success, errorString) in
                    
                    dispatch_async(dispatch_get_main_queue()){
                        if(success)
                        {
                            dispatch_async(dispatch_get_main_queue())
                            {
                                cell.downloadLabel.hidden=true
                                let alertController = UIAlertController(title: "File Downloaded", message: "\(dropboxFile.fileName!) downloaded successfully", preferredStyle: .Alert)
                                let dismissAction = UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                                alertController.addAction(dismissAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                        else
                        {
                            cell.downloadLabel.hidden=true
                            
                            let alertController = UIAlertController(title: "Error Downloading \(dropboxFile.fileName!)", message: errorString!, preferredStyle: .Alert)
                            let dismissAction = UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                            alertController.addAction(dismissAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
            else
            {
                cell.downloadLabel.hidden=true
                let alertController = UIAlertController(title: "File Already Present", message: "\(dropboxFile.fileName!) already present", preferredStyle: .Alert)
                let dismissAction = UIKit.UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                alertController.addAction(dismissAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
        let previewFileAction=UIAlertAction(title: "Preview Document", style: .Default)
        { (UIAlertAction) in
            let fileVC=self.storyboard?.instantiateViewControllerWithIdentifier("fileViewController") as! FileViewController
            fileVC.dropboxFile=dropboxFile
            self.navigationController?.pushViewController(fileVC, animated: true)
        }
        
        
        let dismissAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(downloadFileAction)
        alertController.addAction(previewFileAction)
        alertController.addAction(dismissAction)
        alertController.actions[1].enabled = dropboxFile.fileData==nil ? false : true
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        
    }
    
}


