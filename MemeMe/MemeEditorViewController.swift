//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Online Training on 5/11/16.
//  Copyright © 2016 Mitch Salcido. All rights reserved.
//
/*
 About MemeEditorViewController.swift:
 */

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // ref to view objects: imageView and textFields
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // show top/bottom textFields only if an image is visible
        if imageView.image != nil {
            
            topTextField.hidden = false
            bottomTextField.hidden = false
        }
        else {
            topTextField.hidden = true
            bottomTextField.hidden = true
        }
    }
    
    // function to invoke UIImagePickerViewController
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
        
        // imagePicker has selected and image, get image and show in imageView
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

