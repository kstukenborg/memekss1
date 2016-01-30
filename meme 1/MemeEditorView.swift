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
    struct Meme {
        
        var topText : String
        var bottomText : String
        var originalImage : UIImage
        var memedImage : UIImage
        
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
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
        
        
    }
    override func viewWillAppear(animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        self.navigationController?.toolbarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func subscribeToKeyboardNotifications(){
        print("subscribeToKeyboardNotifications")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:" , name: UIKeyboardWillHideNotification, object:nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("viewWillDisappear")
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    func unsubscribeToKeyboardNotifications(){
        print("unsubscribeToKeyboardNotifications")
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) -> Void{
        print("keyboardWillShow")
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }else if topTextField.isFirstResponder(){
            self.view.frame.origin.y = 0
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        print("keyboardWillHide")
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
        self.navigationController?.toolbarHidden = false
        self.navigationController?.navigationBarHidden = false

        
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        print("in getKeyboardHeight")
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        print(keyboardSize.CGRectValue().height)
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
        
    }
    
    /* This function brings up Apple's stock ACtivity View, displaying several options for sharing the meme.
    */
    func save() {
        //Create the meme
        
        // let meme = Meme( text: topTextField.text!, image:
        //   imageView.image, memedImage: memedImage)
        let meme = Meme( topText: topTextField.text!,  bottomText: bottomTextField.text!,originalImage:
            pictureDisplayed.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage
    {
        print("beginning of generateMemedImage")
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
        print("end of generateMemedImage")

        return memedImage
    }

    @IBAction func shareAction(sender: AnyObject) {
        /*

        1.generate a memed image
        2.define an instance of the ActivityViewController
        3.pass the ActivityViewController a memedImage as an activity item
        4.present the ActivityViewController
*/
        
       let memeImage1 = generateMemedImage()
       // let textToShare = "I'm going to share the meme in 2.0, this is just a test!"
        
        
            let objectsToShare = [memeImage1]
            //let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
            print("just presented share")
            
            
            //pictureDisplayed.image = nil
            //topTextField.text = "TOP"
            //bottomTextField.text = "BOTTOM"
           // self.navigationController?.toolbarHidden = false
            
            
            
        }
        func resetMemeEditorView() {
            pictureDisplayed.image = nil
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            shareOutlet.enabled = false
        }
        
        
    
    
}
