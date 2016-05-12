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
    
    @IBOutlet var tapGr: UITapGestureRecognizer!
    // toolbar items, camera and album bbi's
    var cameraBbi: UIBarButtonItem!
    var albumBbi: UIBarButtonItem!

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
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        // enable bbi's based on availability on device app being run on
        cameraBbi.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        albumBbi.enabled = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        
        // add bbi's to toolbar
        toolbarItems = [flexBbi, cameraBbi, flexBbi, albumBbi, flexBbi]
        
        // textFields
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // show top/bottom textFields only if an image is visible
        if imageView.image != nil {
            
            topTextField.hidden = false
            bottomTextField.hidden = false
        }
        else {
            topTextField.hidden = true
            bottomTextField.hidden = true
        }
        
        // begin keyboard notifications..used to shift bottom keybboard up when editing
        beginKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop keyboard notifications while view not visible
        stopKeyboardNotifications()
    }
    
    // begin notifications for keyboard show
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
    
    // stop notifications for keyboard show
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
    
    // textField delegate function
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // dim image when editing text
        imageView.alpha = 0.5
    }
    
    // textField delegate function
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
    
    // action for tap gr
    @IBAction func tapDetected(sender: UITapGestureRecognizer) {
        
        // end editing
        if topTextField.editing || bottomTextField.editing {
            
            view.endEditing(true)
        }
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
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // imagePickerController delegate function
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        // cancel image selection
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // imagePickerController delegate function
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // imagePicker has selected an image, get image and show in imageView
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
