//
//  SharedMemesTableViewController.swift
//  MemeMe
//
//  Created by Online Training on 5/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About SharedMemesTableViewController.swift:
 
 VC provides functionality to present shared Memes in a tableView. Cells can be selected which prompts
 a detail meme view using MemeViewController
 */

import UIKit

class SharedMemesTableViewController: UITableViewController {

    // ref to shared memes
    var memes: [Meme] {
        get {
            // get shared memes
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memes
        }
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create new Meme bbi
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
                                                            target: self,
                                                            action: #selector(SharedMemesTableViewController.newMemeBbiPressed(_:)))
        
        // launch MemeEditorVC if no shared memes
        if memes.count == 0 {
            newMemeBbiPressed(nil)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tabBar, reload table
        self.tabBarController?.tabBar.hidden = false
        tableView.reloadData()
    }
    
    // MARK: - Table view data source functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }

    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SharedMemeTableViewCellID",
                                                               forIndexPath: indexPath)

        let meme = memes[indexPath.row]
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

    // MARK: - Table view delegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let meme = memes[indexPath.row]
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        vc.meme = meme
        self.tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // MARK: - Launch Meme Editor
    func newMemeBbiPressed(sender: UIBarButtonItem?) {
        
        // create MemeEditor embedded in navController
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        let nc = UINavigationController(rootViewController: vc)
        
        // animate presentation if invocation of this function was a result of newMemeBbi pressed "+"
        if let _ = sender {
            presentViewController(nc, animated: true, completion: nil)
        }
        else {
            // invocation as a result of no saved memes in viewDidLoad (e.g. initial app launch)
            presentViewController(nc, animated: false, completion: nil)
        }
    }
}
