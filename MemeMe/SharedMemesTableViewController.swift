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
 a detail meme view using MemeViewController. Editing of Memes is available (delete/move).
 */


import UIKit

class SharedMemesTableViewController: UITableViewController {
    
    // ref to app delegate..Meme store is defined in appDelegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    // ref to newMemeBbi
    var newMemeBBi: UIBarButtonItem!
    
    // used to steer app to bring up MemeEditor if no memes available at app startup
    var firstRun: Bool = true
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // edit/done bbi on left navbar
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // create new Meme bbi
        newMemeBBi = UIBarButtonItem(barButtonSystemItem: .Add,
                                     target: self,
                                     action: #selector(SharedMemesTableViewController.newMemeBbiPressed(_:)))
        navigationItem.rightBarButtonItem = newMemeBBi
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tabBar, reload table
        tabBarController?.tabBar.hidden = false
        tableView.reloadData()
        
        // enable edit bbi only if Memes
        editButtonItem().enabled = appDelegate.memes.count > 0
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // launch meme editor at app launch if no shared memes, but not again unless user prompted
        if firstRun && appDelegate.memes.count == 0 {
            
            createDebugMemes()
            newMemeBbiPressed(nil)
            firstRun = false
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // allow editing and switching tabs only if NOT editing cells
        newMemeBBi.enabled = !editing
        tabBarController?.tabBar.hidden = editing
    }
    
    // MARK: - Table view data source functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // count of Memes
        return appDelegate.memes.count
    }

    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // get a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("SharedMemeTableViewCellID",
                                                               forIndexPath: indexPath)

        // retrieve Meme from shared store, set image and text
        let meme = appDelegate.memes[indexPath.row]
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

    // MARK: - Table view delegate functions
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // cell selected. Navigate to MemeDetailVC
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        vc.memeIndex = indexPath.row
        
        // hide tab, push VC
        self.tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // OK to edit cell
        return true
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        // can move only if more that one meme
        return appDelegate.memes.count > 1
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            // delete meme and remove cell
            appDelegate.memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // if no memes, remove from editing
            if appDelegate.memes.count == 0 {
                
                setEditing(false, animated: true)
                editButtonItem().enabled = false
            }
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        // move meme
        let meme = appDelegate.memes.removeAtIndex(sourceIndexPath.row)
        appDelegate.memes.insert(meme, atIndex: destinationIndexPath.row)
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
    
    // MARK: - Helper Functions
    func createDebugMemes() {
        
        // create five memes and add to Store...used for debug
        let image = UIImage(named: "testImage")
        let memedImage = UIImage(named: "testImage")

        var i = 1;
        while (i < 6) {
            
            let topText = "Top Text Meme \(i)"
            let bottomText = "Bottom Text Meme \(i)"
            let newMeme = Meme(topText: topText, bottomText: bottomText, originalImage: image, memedImage: memedImage)
            appDelegate.memes.append(newMeme)
            i = i + 1
        }
    }
}
