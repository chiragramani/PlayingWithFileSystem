//
//  DocumentsViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 01/08/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit
import CoreData

class DocumentsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sortingDescriptor = "fileName"
    
    
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
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellId") as! CustomTableViewCell
        let file=fetchedResultsController.objectAtIndexPath(indexPath) as! File
        cell.fileNameLabel.text=file.fileName
        
        let formatter = NSByteCountFormatter()
        formatter.allowsNonnumericFormatting = false
        let bytes=file.fileSize?.longLongValue
        
        cell.fileSizeLabel.text=formatter.stringFromByteCount(bytes!)
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
        default : break
        }
        return cell
    }
    
    
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let file=fetchedResultsController.objectAtIndexPath(indexPath) as! File
        let fileVC=storyboard?.instantiateViewControllerWithIdentifier("fileViewController") as! FileViewController
        fileVC.file=file
        navigationController?.pushViewController(fileVC, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete)
        {
            let file=fetchedResultsController.objectAtIndexPath(indexPath) as! File
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let stack = delegate.stack
            stack.context.deleteObject(file)
            tableView.reloadData()
            let alert = UIAlertController(title: "Notification!",message:"File \(file.fileName!) deleted",preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            do
            {       try stack.saveContext()
            }catch
            {
                print("Error saving context")
            }
        }
    }
    
    
    @IBAction func moreBarItemPressed(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil , message: nil, preferredStyle: .ActionSheet)
        
        let createNonDLPFileAction=UIAlertAction(title: "Create Non-DLP File", style: .Default)
        { (UIAlertAction) in
            let newFileVC=self.storyboard?.instantiateViewControllerWithIdentifier("newFileVC") as! newFileViewController
            self.navigationController?.pushViewController(newFileVC, animated: true)
            
        }
        let createDLPFileAction=UIAlertAction(title: "Create DLP File", style: .Default, handler: nil)
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
            
            let sortByCategory=UIKit.UIAlertAction(title: "Category-DLP", style: .Default, handler: nil)
            let cancelAction=UIKit.UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(sortByName)
            alertController.addAction(sortBySize)
            alertController.addAction(sortByFileType)
            alertController.addAction(sortByCategory)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        let cancelAction=UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(createDLPFileAction)
        alertController.addAction(createNonDLPFileAction)
        alertController.addAction(sortFileAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
