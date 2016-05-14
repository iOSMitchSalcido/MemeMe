//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Online Training on 5/11/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About MemeEditorViewController.swift:
 
 VC provides functionality to take a snapshot (or select a photo from photo album), and then
 create a Meme by adding text at top and bottom of photo:
 - invoke imagePicker when "album" or "camera"(if available on ios device) bbi on toolbar is pressed
 - place image on imageView on ios device screen
 - provide editing of textFields at top/bottom of photo to customize Meme
 - share Meme using activityViewController
 */

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    // ref to view objects: imageView and textFields
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // toolbar items, camera and album bbi's
    var cameraBbi: UIBarButtonItem!
    var albumBbi: UIBarButtonItem!
    
    // navbar bbi, share meme
    var shareMemeBbi: UIBarButtonItem!
    
    // Meme, saved after Meme is shared
    var meme: Meme?
    
    // track which text style in in text field, used to edit textField font
    var textAttribIndex: Int = 0
    var memeTextAttribArray = [[String:AnyObject]]()
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show toolbar
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        // create bbi's for selecting image, camera and photo album..also create flexible bbi for spacing
        cameraBbi = UIBarButtonItem(barButtonSystemItem: .Camera,
                                    target: self,
                                    action: #selector(MemeEditorViewController.pickAnImage(_:)))
        albumBbi = UIBarButtonItem(title: "Album",
                                   style: .Plain,
                                   target: self,
                                   action: #selector(MemeEditorViewController.pickAnImage(_:)))
        
        // enable bbi's based on availability on device that app being run on
        cameraBbi.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        albumBbi.enabled = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        
        // share meme bbi on left navbar
        shareMemeBbi = UIBarButtonItem(barButtonSystemItem: .Action,
                                       target: self,
                                       action: #selector(MemeEditorViewController.shareMemeBbiPressed(_:)))
        self.navigationItem.leftBarButtonItem = shareMemeBbi
        
        // add edit button to right navbar
        self.navigationItem.rightBarButtonItem = editButtonItem()

        // add a few fonts to memeTextAttribArray for user selection when editing meme
        let impactTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ]
        let textAttributes1 = [
            NSStrokeColorAttributeName : UIColor.redColor(),
            NSForegroundColorAttributeName : UIColor.greenColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ]
        let textAttributes2 = [
            NSStrokeColorAttributeName : UIColor.blueColor(),
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ]
        let textAttributes3 = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 3.0,
            ]
        memeTextAttribArray.append(impactTextAttributes)
        memeTextAttribArray.append(textAttributes1)
        memeTextAttribArray.append(textAttributes2)
        memeTextAttribArray.append(textAttributes3)
        
        // config textFields
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.defaultTextAttributes = memeTextAttributes(textAttribIndex)
        bottomTextField.defaultTextAttributes = memeTextAttributes(textAttribIndex)
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // configure toolbar
        configureToolbar(false)
        
        // show top/bottom textFields only if an image is visible
        // enable shareMeme and Preview Meme only if image is visible
        if imageView.image != nil {
            
            topTextField.hidden = false
            bottomTextField.hidden = false
            shareMemeBbi.enabled = true
            editButtonItem().enabled = true
        }
        else {
            //topTextField.hidden = true
            //bottomTextField.hidden = true
            shareMemeBbi.enabled = false
            editButtonItem().enabled = false
        }
        
        // begin keyboard notifications..used to shift bottom keybboard up when editing
        beginKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop keyboard notifications while view not visible
        stopKeyboardNotifications()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        configureToolbar(editing)
    }
    
    //MARK: Keyboard notification functions
    // begin notifications for keyboard show/hide
    func beginKeyboardNotifications() {
     
        // begin show notification
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MemeEditorViewController.keyboardWillShow(_:)),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        
        // begin hide notification
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MemeEditorViewController.keyboardWillHide(_:)),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
    }
    
    // stop notifications for keyboard show/hide
    func stopKeyboardNotifications() {
        
        // end show notification
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIKeyboardWillShowNotification,
                                                            object: nil)
        // end hide notification
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: UIKeyboardWillHideNotification,
                                                            object: nil)
    }
    
    // keyboard about to show
    func keyboardWillShow(notification: NSNotification) {
        
        // shift up only if bottomTextField is editing
        if bottomTextField.editing {
            
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // keyboard about to hide
    func keyboardWillHide(notification: NSNotification) {
        
        // shift back down only if previously shifted up
        if view.frame.origin.y < 0.0 {
            
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    // return keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //MARK: BBI Action functions
    // shareMeme bbi pressed
    func shareMemeBbiPressed(sender: UIBarButtonItem) {
        
        // take a screen shot, use as item in ActivityViewController
        let memedImage = screenShot()
        let vc = UIActivityViewController(activityItems: ["Check out my Meme !", memedImage], applicationActivities: nil)
        
        // completion for ActivityViewController. Save meme if successful share
        vc.completionWithItemsHandler = {(activityType: String?, completed: Bool,
            returnedItems: [AnyObject]?, error: NSError?) -> Void in
            
            if completed {
                // Meme share was completed successfully, same Meme
                self.meme = Meme(topText: self.topTextField.text,
                                 bottomText: self.bottomTextField.text,
                                 originalImage: self.imageView.image,
                                 memedImage: memedImage)
            }
        }
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // function to create/invoke UIImagePickerViewController
    func pickAnImage(sender: UIBarButtonItem) {
        
        // create imagePick, set photo source based on bbi that was pressed
        let imagePickerController = UIImagePickerController()
        if sender == cameraBbi {
            imagePickerController.sourceType = .Camera
        }
        else if sender == albumBbi {
            imagePickerController.sourceType = .PhotoLibrary
        }
        
        // set delegate and present
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // function to change font in textFields
    func fontBbiPressed(sender: UIBarButtonItem) {
        
        textAttribIndex += 1
        if textAttribIndex >= memeTextAttribArray.count {
            textAttribIndex = 0
        }
        topTextField.defaultTextAttributes = memeTextAttribArray[textAttribIndex]
        bottomTextField.defaultTextAttributes = memeTextAttribArray[textAttribIndex]
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
    }
    
    //MARK: UIImagePicker Delegate functions
    // imagePickerController delegate function
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // cancel image selection
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // UIImageImagePickerController delegate function
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // imagePicker has selected an image, get image and show in imageView
        // ..save edited image if available
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = editedImage
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = originalImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITextField Delegate functions
    // textField delegate function
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // dim image when editing text
        imageView.alpha = 0.5
    }
    
    // TextField delegate function
    func textFieldDidEndEditing(textField: UITextField) {
        
        // un-dim image when done editing text
        imageView.alpha = 1.0
    }
    
    // textField delegate function
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // return button ends editing, hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UITapGestureRecognizer functions
    // action for tap gr
    @IBAction func tapDetected(sender: UITapGestureRecognizer) {
        
        // end editing
        if topTextField.editing || bottomTextField.editing {
            
            view.endEditing(true)
        }
    }
    
    //MARK: Helper functions
    
    // take a screenshot of iOS device screen, return "Meme'd" image
    func screenShot() -> UIImage {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let image : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // configure toolbar/navbar for when editing Meme
    func configureToolbar(editing: Bool) {
        
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
                                      target: nil,
                                      action: nil)
        
        var items: [UIBarButtonItem]!
        if editing {
            
            shareMemeBbi.enabled = false
            
            let editFontBbi = UIBarButtonItem(title: "Font",
                                              style: .Plain,
                                              target: self,
                                              action: #selector(MemeEditorViewController.fontBbiPressed(_:)))
            
            items = [flexBbi, editFontBbi, flexBbi]
            
        }
        else {
            
            shareMemeBbi.enabled = true
            items = [flexBbi, cameraBbi, flexBbi, albumBbi, flexBbi]
        }
        
        self.setToolbarItems(items, animated: true)
    }
    
    // return a dictionary of textAttribs
    func memeTextAttributes(index: Int) -> [String: AnyObject] {
        
        let textAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ]
        
        return textAttributes
    }
}
