//
//  ViewController.swift
//  PickImage
//
//  Created by Dan on 3/3/17.
//  Copyright © 2017 Dan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate{

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    var memedImage: UIImage?
    
    let textFieldDelegate = TextFieldDelegate()
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.black,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: 8]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        topTextField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.delegate = textFieldDelegate
        bottomTextField.delegate = textFieldDelegate
        
        subscribeToKeyboardNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboard()
    }
    
    func pickAnImage(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        self.present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .camera
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: Any) {
        print("saving")
        save()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            print("imageFound")
            imagePickerView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    //move view up when choosing bottom text field
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow(_:)), name:
            NSNotification.Name.UIKeyboardWillShow, object:nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //pushes view up when keyboard comes up
    func keyboardWillShow(_ notification: NSNotification){
        self.view.frame.origin.y -= getKeyBoardHeight(notification: notification)
    }
    
    //pulls view back down
    func keyboardWillDisappear(_ notification: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    //returns Keyboard height
    func getKeyBoardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboard = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboard.cgRectValue.height
    }
    
    //unsubscribe from keyboard notification
    func unsubscribeFromKeyboard(){
        NotificationCenter.default.removeObserver(self)
    }
    
    //Saves screenshot into Meme
    func save(){
        let meme = Meme(bottomText: bottomTextField.text!, topText: topTextField.text!, originalImage: imagePickerView.image!, memedImage: genMemedImage())
        UIImageWriteToSavedPhotosAlbum(meme.memedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//        if let data = UIImagePNGRepresentation(meme.memedImage){
//            let fileName = getDocumentsDirectory().appendingPathComponent("meme.png")
//            try? data.write(to: fileName)
//        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let e = error{
            print("error exists")
        }else{
            print("no error")
        }
    }
    
    //returns document directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //generates memedImage from screen
    func genMemedImage() -> UIImage{
        //hide toolbar and navbar
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show toolbar and navbar
        
        return memedImage
    }
}

