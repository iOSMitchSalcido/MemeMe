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
    
    // toolbar items, camera, album, and editFont bbi's
    var cameraBbi: UIBarButtonItem!
    var albumBbi: UIBarButtonItem!
    var editFontBbi: UIBarButtonItem!
    
    // navbar bbi, share meme
    var shareMemeBbi: UIBarButtonItem!
    
    // Meme, saved after Meme is shared
    var meme: Meme?
    
    // image picked from camer/album
    var photoImage: UIImage?
    
    // array of fonts. For user customization.
    // font's are added in viewDidLoad. When user presses "Font" bbi, fonts
    // are cycled thru
    var memeTextAttribArray = [[String:AnyObject]]()

    // index to track which font is in textFields. Is incremented when user presses Font bbi
    // upper limit is count of memeTextAttribArray, then it's set back to 0
    var textAttribIndex: Int = 0
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show toolbar
        navigationController?.setToolbarHidden(false, animated: false)
        
        // create bbi's for selecting image, camera and photo album..also create flexible bbi for spacing
        cameraBbi = UIBarButtonItem(barButtonSystemItem: .camera,
                                    target: self,
                                    action: #selector(MemeEditorViewController.pickAnImage(_:)))
        albumBbi = UIBarButtonItem(title: "Album",
                                   style: .plain,
                                   target: self,
                                   action: #selector(MemeEditorViewController.pickAnImage(_:)))
        editFontBbi = UIBarButtonItem(title: "Font",
                                      style: .plain,
                                      target: self,
                                      action: #selector(MemeEditorViewController.fontBbiPressed(_:)))
        
        // flex bbi for spacing
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // set toolbar
        toolbarItems = [flexBbi, cameraBbi, flexBbi, albumBbi, flexBbi, editFontBbi, flexBbi]
        
        // enable bbi's based on availability on device that app being run on
        cameraBbi.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        albumBbi.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
        // share meme bbi on left navbar
        shareMemeBbi = UIBarButtonItem(barButtonSystemItem: .action,
                                       target: self,
                                       action: #selector(MemeEditorViewController.shareMemeBbiPressed(_:)))
        navigationItem.leftBarButtonItem = shareMemeBbi

        // cancel bbi on right navbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                            target: self,
                                                            action: #selector(MemeEditorViewController.cancelBbiPressed(_:)))
        
        // add a few fonts to memeTextAttribArray for user selection when editing meme
        let impactTextAttributes = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ] as [String : Any]
        let textAttributes1 = [
            NSStrokeColorAttributeName : UIColor.red,
            NSForegroundColorAttributeName : UIColor.green,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ] as [String : Any]
        let textAttributes2 = [
            NSStrokeColorAttributeName : UIColor.blue,
            NSForegroundColorAttributeName : UIColor.black,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -2.0,
            ] as [String : Any]
        let textAttributes3 = [
            NSStrokeColorAttributeName : UIColor.black,
            NSForegroundColorAttributeName : UIColor.white,
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 3.0,
            ] as [String : Any]
        memeTextAttribArray.append(impactTextAttributes as [String : AnyObject])
        memeTextAttribArray.append(textAttributes1 as [String : AnyObject])
        memeTextAttribArray.append(textAttributes2 as [String : AnyObject])
        memeTextAttribArray.append(textAttributes3 as [String : AnyObject])
        
        // config textFields
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.defaultTextAttributes = memeTextAttribArray[textAttribIndex]
        bottomTextField.defaultTextAttributes = memeTextAttribArray[textAttribIndex]
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show top/bottom textFields only if an image is visible
        // enable shareMeme and Preview Meme, Font, only if image is visible
        if photoImage != nil {
            
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            shareMemeBbi.isEnabled = true
            editFontBbi.isEnabled = true
        }
        else {
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            shareMemeBbi.isEnabled = false
            editFontBbi.isEnabled = false
        }
        
        // begin keyboard notifications..used to shift bottom keybboard up when editing
        beginKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // stop keyboard notifications while view not visible
        stopKeyboardNotifications()
    }
    
    //MARK: Keyboard notification functions
    // begin notifications for keyboard show/hide
    func beginKeyboardNotifications() {
     
        // begin show notification
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(MemeEditorViewController.keyboardWillShow(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillShow,
                                                         object: nil)
        
        // begin hide notification
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(MemeEditorViewController.keyboardWillHide(_:)),
                                                         name: NSNotification.Name.UIKeyboardWillHide,
                                                         object: nil)
    }
    
    // stop notifications for keyboard show/hide
    func stopKeyboardNotifications() {
        
        // end show notification
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name.UIKeyboardWillShow,
                                                            object: nil)
        // end hide notification
        NotificationCenter.default.removeObserver(self,
                                                            name: NSNotification.Name.UIKeyboardWillHide,
                                                            object: nil)
    }
    
    // keyboard about to show
    func keyboardWillShow(_ notification: Notification) {
        
        // shift up only if bottomTextField is editing
        if bottomTextField.isEditing {
            
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // keyboard about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        // shift back down only if previously shifted up
        if view.frame.origin.y < 0.0 {
            
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    // return keyboard height
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //MARK: BBI Action functions
    // shareMeme bbi pressed
    func shareMemeBbiPressed(_ sender: UIBarButtonItem) {
        
        // take a screen shot, use as item in ActivityViewController
        let memedImage = screenShot()

        let vc = UIActivityViewController(activityItems: ["Check out my Meme !", memedImage], applicationActivities: nil)

        // completion for ActivityViewController. Save meme if successful share
        vc.completionWithItemsHandler = {(activityType, completed,
            returnedItems, error) in
            
            if completed {
                // Meme share was completed successfully, save Meme
                self.meme = Meme(topText: self.topTextField.text,
                                 bottomText: self.bottomTextField.text,
                                 originalImage: self.imageView.image,
                                 memedImage: memedImage)
                
                // save meme
                self.saveMeme()
                
                // dismiss
                self.cancelBbiPressed(nil)
            }
        }
 
        present(vc, animated: true, completion: nil)
    }
    
    // function to create/invoke UIImagePickerViewController
    func pickAnImage(_ sender: UIBarButtonItem) {
        
        // create imagePick, set photo source based on bbi that was pressed
        let imagePickerController = UIImagePickerController()
        if sender == cameraBbi {
            imagePickerController.sourceType = .camera
        }
        else if sender == albumBbi {
            imagePickerController.sourceType = .photoLibrary
        }
        
        // set delegate and present
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // function to change font in textFields
    func fontBbiPressed(_ sender: UIBarButtonItem) {
        
        textAttribIndex += 1
        if textAttribIndex >= memeTextAttribArray.count {
            textAttribIndex = 0
        }
        topTextField.defaultTextAttributes = memeTextAttribArray[textAttribIndex]
        bottomTextField.defaultTextAttributes = memeTextAttribArray[textAttribIndex]
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
    }
    
    //MARK: UIImagePicker Delegate functions
    // imagePickerController delegate function
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // cancel image selection
        dismiss(animated: true, completion: nil)
    }
    
    // UIImageImagePickerController delegate function
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // imagePicker has selected an image, get image and show in imageView
        // ..save edited image if available
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.image = editedImage
            photoImage = imageView.image
        }
        else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = originalImage
            photoImage = imageView.image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextField Delegate functions
    // textField delegate function
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // dim image when editing text
        imageView.alpha = 0.5
        
        // disable share when editing text
        shareMemeBbi.isEnabled = false
    }
    
    // TextField delegate function
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // un-dim image when done editing text
        imageView.alpha = 1.0
        
        // enable share button when not editing text
        shareMemeBbi.isEnabled = true
    }
    
    // textField delegate function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // return button ends editing, hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: UITapGestureRecognizer functions
    // action for tap gr
    @IBAction func tapDetected(_ sender: UITapGestureRecognizer) {
        
        // end editing
        if topTextField.isEditing || bottomTextField.isEditing {
            
            view.endEditing(true)
        }
    }
    
    //MARK: Helper functions
    
    // take a screenshot of iOS device screen, return "Meme'd" image
    func screenShot() -> UIImage {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
                                     afterScreenUpdates: true)
        let image : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // save Meme in Shared model defined in AppDelegate
    func saveMeme() {
        
        if let meme = self.meme {
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes.append(meme)
        }
    }
    
    // cancel/dismiss meme creation
    func cancelBbiPressed(_ sender: UIBarButtonItem?) {
        
        dismiss(animated: true, completion: nil)
    }
}
