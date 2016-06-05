//
//  SharedMemesCollectionViewController.swift
//  MemeMe
//
//  Created by Online Training on 5/30/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About SharedMemesCollectionViewController.swift:
 
 VC provides functionality to present shared Memes in a collectionView. Cells can be selected which prompts
 a detail meme view using MemeViewController.
 */

import UIKit

class SharedMemesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // ref to app delegate
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create new Meme bbi
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add,
                                                            target: self,
                                                            action: #selector(SharedMemesTableViewController.newMemeBbiPressed(_:)))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tabBar, reload table
        self.tabBarController?.tabBar.hidden = false
        
        collectionView?.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("viewWillLayoutSubviews")
        guard let flowLayout = collectionView!.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let width = UIScreen.mainScreen().bounds.width
        flowLayout.itemSize = CGSize(width: width / 4.0 - 4.0, height: width / 4.0 - 4.0)
        
        flowLayout.invalidateLayout()
        
        return
        
        let space: CGFloat = 1.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 2.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
        flowLayout.invalidateLayout()
    }
    
    // MARK: UICollectionViewDataSource functions
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return appDelegate.memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SharedMemesCollectionViewCellID",
                                                                         forIndexPath: indexPath) as! SharedMemesCollectionViewCell
        // Configure the cell
        let meme = appDelegate.memes[indexPath.row]
        cell.imageView.image = meme.memedImage
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = UIScreen.mainScreen().bounds.width
        return CGSize(width: width / 3.0 - 2.0, height: width / 3.0 - 2.0)
    }
    
    // MARK: UICollectionViewDelegate functions
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // cell selected. Navigate to MemeVC
        let meme = appDelegate.memes[indexPath.row]
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        vc.meme = meme
        
        // hide tab, push VC
        self.tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

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
