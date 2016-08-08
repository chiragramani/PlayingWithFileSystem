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
        activityView.hidden=true
        tableView.delegate=self
        tableView.dataSource=self
        configureAuthenticateButton()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Dropbox1ViewController.userAuthenticated), name: "userAuthenticated", object: nil)
        performFetch()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        configureUI()
    }
    
    func configureUI()
    {
        let access_token = (DropboxClient.sharedInstance.access_token)
        tableView.hidden = (access_token==nil) ? true : false
        authenticateButton.hidden = (access_token==nil) ? false : true
        dropboxLogo.alpha = (access_token==nil) ? CGFloat(1.0) : CGFloat(0.5)
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
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell=tableView.dequeueReusableCellWithIdentifier("CellId") as! Custom1TableViewCell
        let dropboxFile=fetchedResultsController.objectAtIndexPath(indexPath) as! DropboxFile
        
        cell.fileNameLabel.text=dropboxFile.fileName
        let formatter = NSByteCountFormatter()
        cell.fileNameLabel.numberOfLines=0
        formatter.allowsNonnumericFormatting = false
        formatter.includesActualByteCount=true
        let bytes=dropboxFile.fileSize?.longLongValue
        
        cell.fileSizeLabel.text=formatter.stringFromByteCount(bytes!)
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
            
        default : break
        }
        cell.layoutSubviews()
        //cell.fileNameLabel.text=dropboxFile.fileName
        //cell.fileSizeLabel.text=String(dropboxFile.fileSize)
        
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
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
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
            
            if(success)
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.tableView.reloadData()
                    self.activityView.stopAnimating()
                    self.activityView.hidden=true
                    let delegate=UIApplication.sharedApplication().delegate as! AppDelegate
                    let stack=delegate.stack
                    do
                    {       try stack.saveContext()
                    }catch
                    {
                        print("Error saving context")
                    }
                }}
            else
            {
                self.activityView.stopAnimating()
                self.activityView.hidden=true
                print(errorString)
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell=tableView.cellForRowAtIndexPath(indexPath) as! Custom1TableViewCell
        cell.activityView.startAnimating()
        cell.activityView.hidden=false
        let dropboxFile = fetchedResultsController.objectAtIndexPath(indexPath) as! DropboxFile
        if dropboxFile.fileData == nil
        {
            DropboxClient.sharedInstance.downloadFile(dropboxFile) { (success, errorString) in
                if(success)
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                    cell.activityView.stopAnimating()
                    cell.activityView.hidden=true
                    let alertController = UIAlertController(title: "File Downloaded", message: "\(dropboxFile.fileName!) downloaded successfully", preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                        alertController.addAction(dismissAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                       
                    
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        cell.activityView.stopAnimating()
                        cell.activityView.hidden=true
                        let alertController = UIAlertController(title: "Error Downloading File", message: "\(dropboxFile.fileName!) download failed..Try Again", preferredStyle: .Alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                         alertController.addAction(dismissAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                    }
                }
            }
        }
        else
        {
            cell.activityView.stopAnimating()
            cell.activityView.hidden=true
        print("Already download")//NSdata already present
        }
        
    }
}


