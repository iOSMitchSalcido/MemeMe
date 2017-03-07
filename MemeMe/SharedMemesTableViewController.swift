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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // ref to newMemeBbi
    var newMemeBBi: UIBarButtonItem!
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // edit/done bbi on left navbar
        navigationItem.leftBarButtonItem = editButtonItem
        
        // create new Meme bbi
        newMemeBBi = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(SharedMemesTableViewController.newMemeBbiPressed(_:)))
        navigationItem.rightBarButtonItem = newMemeBBi
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tabBar, reload table
        tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
        
        // enable edit bbi only if Memes
        editButtonItem.isEnabled = appDelegate.memes.count > 0
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // allow editing and switching tabs only if NOT editing cells
        newMemeBBi.isEnabled = !editing
        tabBarController?.tabBar.isHidden = editing
    }
    
    // MARK: - Table view data source functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // count of Memes
        return appDelegate.memes.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SharedMemeTableViewCellID",
                                                               for: indexPath)

        // retrieve Meme from shared store, set image and text
        let meme = appDelegate.memes[indexPath.row]
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

    // MARK: - Table view delegate functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // cell selected. Navigate to MemeDetailVC
        let vc = storyboard?.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        vc.memeIndex = indexPath.row
        
        // hide tab, push VC
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // OK to edit cell
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        // can move only if more that one meme
        return appDelegate.memes.count > 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // delete meme and remove cell
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // if no memes, remove from editing
            if appDelegate.memes.count == 0 {
                
                setEditing(false, animated: true)
                editButtonItem.isEnabled = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // move meme
        let meme = appDelegate.memes.remove(at: sourceIndexPath.row)
        appDelegate.memes.insert(meme, at: destinationIndexPath.row)
    }
    
    // MARK: - Launch Meme Editor
    func newMemeBbiPressed(_ sender: UIBarButtonItem?) {
        
        // create MemeEditor embedded in navController
        let vc = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        let nc = UINavigationController(rootViewController: vc)
        
        // animate presentation if invocation of this function was a result of newMemeBbi pressed "+"
        if let _ = sender {
            present(nc, animated: true, completion: nil)
        }
        else {
            // invocation as a result of no saved memes in viewDidLoad (e.g. initial app launch)
            present(nc, animated: false, completion: nil)
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
