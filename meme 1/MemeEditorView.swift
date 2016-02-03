//
//  MemeEditorView.swift
//  meme 1
//
//  Created by Kathleen Stukenborg on 1/7/16.
//  Copyright © 2016 Kathleen Stukenborg. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
/*
The MemeEditorView class allows you to choose a picture, or take a picture and edit two text fields so that you
create a meme.
*/
class MemeEditorView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var takePictureOutlet: UIBarButtonItem!
    @IBOutlet weak var pictureDisplayed: UIImageView!
    @IBOutlet weak var shareOutlet: UIBarButtonItem!
       
    let memeTextAttributes = [
        //black outline
        NSStrokeColorAttributeName : UIColor.blackColor(),
        // white fill
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        //font
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        //outline width 0 means fill it
        NSStrokeWidthAttributeName : -3
        // NSStrokeWidthAttributeName : 0
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationController = UINavigationController()
        navigationController.delegate = self
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
        shareOutlet.enabled = false
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment  = NSTextAlignment.Center
        topTextField.backgroundColor = UIColor.clearColor()
        topTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        bottomTextField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        topTextField.text = "TOP"
        bottomTextField.backgroundColor = UIColor.clearColor()
        bottomTextField.text  = "BOTTOM"
        bottomTextField.textAlignment  = NSTextAlignment.Center
        takePictureOutlet.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        self.navigationController?.toolbarHidden = false
        self.navigationController?.view.backgroundColor = UIColor.blackColor()
        self.dismissViewControllerAnimated(true, completion: nil)
        topTextField.enabled = false
        bottomTextField.enabled = false
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        self.navigationController?.toolbarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    This function allows us to get notifications on the status of the keyboard.
    */
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    
    func unsubscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) -> Void{
        if bottomTextField.isFirstResponder(){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
        else if topTextField.isFirstResponder(){
            self.view.frame.origin.y = 0
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
        self.navigationController?.toolbarHidden = false
        self.navigationController?.navigationBarHidden = false
    }
    /*
    We use this function to get the keyboard height so that we can scroll up the view and still see the
    textfield we are editing even though the keyboard is shown.
    */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    /*
    This function allows us to take a picture to be used in the meme.
    */
    @IBAction func takeAPictureUsingCamera(sender: AnyObject) {
        topTextField.enabled = true
        bottomTextField.enabled = true
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    /*
    This function allows the user to pick a picture from the pictures in albums.
    */
    
    @IBAction func pickAnImage(sender: AnyObject) {
        topTextField.enabled = true
        bottomTextField.enabled = true
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    /*
    This function sets the picture the user selects to be the image displayed in the memeEditorView
    */
    func imagePickerController( _picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage  {
                self.pictureDisplayed.image = image
            }
            shareOutlet.enabled = true
            self.dismissViewControllerAnimated(true, completion:nil)
            
    }
    
    func imagePickerControllerDidCancel( _picker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //This function sets meme Editor View back to the launch state
    @IBAction func cancelAction(sender: AnyObject) {
        
        pictureDisplayed.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareOutlet.enabled = false
        topTextField.enabled = false
        bottomTextField.enabled = false
        
    }
    
    /*
    This function creates an object meme and then saves in into the memes structure.
    */
    func save() {
        
        let meme = Meme( topText: topTextField.text!,  bottomText: bottomTextField.text!,originalImage:
            pictureDisplayed.image!, memedImage: generateMemedImage())
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    /*
    This function creates the memedImage.
    */
    func generateMemedImage() -> UIImage
    {
        self.navigationController?.toolbarHidden = true
        self.navigationController?.navigationBarHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.navigationController?.toolbarHidden = false
        self.navigationController?.navigationBarHidden = false
        return memedImage
    }
    
    /*
    This function calls a function to generate the memed image and that calls a different function to save it and put
    in an array.
    */
    @IBAction func shareAction(sender: AnyObject) {
        let memeImage1 = generateMemedImage()
        let objectsToShare = [memeImage1]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                // call save to save the meme in an array.
                self.save()
                self.dismissViewControllerAnimated(true, completion:nil )
            }
        }
    }
    
}
