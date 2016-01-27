//
//  MemeEditorView.swift
//  meme 1
//
//  Created by Kathleen Stukenborg on 1/7/16.
//  Copyright © 2016 Kathleen Stukenborg. All rights reserved.
//

import Foundation
import UIKit

class MemeEditorView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var takePictureOutlet: UIBarButtonItem!
    @IBOutlet weak var pictureDisplayed: UIImageView!
    
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
        
        
    }
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        self.navigationController?.toolbarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func subscribeToKeyboardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    func unsubscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }else if topTextField.isFirstResponder(){
            self.view.frame.origin.y = 0
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    @IBAction func takeAPictureUsingCamera(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImage(sender: AnyObject) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController( _picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage  {
                self.pictureDisplayed.image = image
                
                
            }
            //in storyboard, set content mode of image to aspect fit
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
        
    }
    
    /* This function brings up Apple's stock ACtivity View, displaying several options for sharing the meme.
    */
    @IBAction func shareAction(sender: AnyObject) {
        
        let textToShare = "I'm going to share the meme in 2.0, this is just a test!"
        
        if let myWebsite = NSURL(string: "http://www.codingexplorer.com/")
        {
            let objectsToShare = [textToShare, myWebsite]
            //let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
            print("just presented share")
            
            
            pictureDisplayed.image = nil
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            self.navigationController?.toolbarHidden = false
            
            
            
        }
        func resetMemeEditorView() {
            pictureDisplayed.image = nil
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
        }
        
    
    
}
}