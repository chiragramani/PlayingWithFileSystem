//
//  ViewController.swift
//  PlayingWithFileSystem
//
//  Created by Chirag Ramani on 30/07/16.
//  Copyright © 2016 Chirag Ramani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet var leftGestureRecognizer: UISwipeGestureRecognizer!
    
    
    @IBOutlet var rightGestureRecognizer: UISwipeGestureRecognizer!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var netskopeImage: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var fileManagerPhoto: UIImageView!
    
    let message = ["File Manager is a FREE file manager and virtual USB drive for the iPhone and iPad. Easily view images, audio, videos, PDF documents, Word documents, Excel documents, ZIP/RAR files and more.","Integration with Amazon Cloud Services"]

    override func viewDidLoad() {
        super.viewDidLoad()
        leftGestureRecognizer.direction=UISwipeGestureRecognizerDirection.Left
        rightGestureRecognizer.direction=UISwipeGestureRecognizerDirection.Right
       fileManagerPhoto.hidden=true
       
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore  {
            performSegueWithIdentifier("launchMainView", sender: self)
        }
        else {
            UIView.animateWithDuration(1, delay: 0.3, options: .CurveEaseIn, animations: {
                self.netskopeImage.center.y=120
            }) { (true) in
                self.fileManagerPhoto.hidden=false
            }
            print("First launch, setting NSUserDefault.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        } 
    }
    
    
    @IBAction func pageSlided(sender: AnyObject) {
        if (pageControl.currentPage==0)
        {
        textView.text=message[0]
        }
        else
        {
        textView.text=message[1]
        }
    }
    
    @IBAction func userSwiped(sender: AnyObject) {
        if(sender.direction==UISwipeGestureRecognizerDirection.Left)
        {
        self.pageControl.currentPage-=1
            pageSlided(self)
        }
        else if(sender.direction==UISwipeGestureRecognizerDirection.Right)
        {
          self.pageControl.currentPage+=1
             pageSlided(self)
        }
        
    }
    

   }

