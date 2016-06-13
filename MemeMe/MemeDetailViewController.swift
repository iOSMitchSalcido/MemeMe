//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Online Training on 5/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About MemeDetailViewController.swift:
 
 VC provides functionality to view a Meme in detail. Also includes edit button to delete or edit the meme
 */

import UIKit

class MemeDetailViewController: UIViewController {

    // ref to app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // ref to index of Meme being view
    var memeIndex: Int?
    
    // ref to view objects
    @IBOutlet weak var deleteMemeButton: UIButton!
    @IBOutlet weak var editMemeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view title
        title = "Meme"
        
        // edit button on right navbar
        navigationItem.rightBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // test for valid index, grab meme and place image in view
        if let index = memeIndex {
            let meme = appDelegate.memes[index]
            imageView.image = meme.memedImage
        }
        
        // disable and hide edit/delete buttons
        deleteMemeButton.enabled = false
        deleteMemeButton.hidden = true
        editMemeButton.enabled = false
        editMemeButton.hidden = true
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // config edit/delete buttons based on editing state
        deleteMemeButton.enabled = editing
        deleteMemeButton.hidden = !editing
        editMemeButton.enabled = editing
        editMemeButton.hidden = !editing
        
        if editing {
            
            // view is editing. Dim Meme image and replace back navbar button with "empty" bbi
            imageView.alpha = 0.5
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: " ",
                                                               style: .Plain, target: nil,
                                                               action: nil)
        }
        else {
            
            // not editing. un-dim Meme, restore back navbar button
            imageView.alpha = 1.0
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    @IBAction func deleteMemeButtonPressed(sender: UIButton) {
        
        /*
         Delete Meme button pressed
         Create a Alert with buttons to Cancel or proceed with Meme deletion
         */
        
        let ac = UIAlertController(title: "Delete Meme ?",
                                   message: "Continuing will remove Meme from saved Memes",
                                   preferredStyle: .ActionSheet)
        
        // create Cancel and Delete actions for Alert
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .Destructive){(action) -> Void in
                                            
                                            // completeion
                                            // remove from memes, pop vc
                                            if let index = self.memeIndex {
                                                self.appDelegate.memes.removeAtIndex(index)
                                                self.navigationController?.popViewControllerAnimated(true)
                                            }
        }
        
        // add actions and show
        ac.addAction(cancelAction)
        ac.addAction(deleteAction)
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func editMemeButtonPressed(sender: UIButton) {
        print("editMemeButtonPressed")
    }
}
