//
//  ViewController.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 15.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var myText: UITextView!
    @IBOutlet weak var textSizeField: UITextField!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var idTextField: UITextField!
    
    
    var backgroundColor: UIColor?
    let defaults = UserDefaults.standard
    var sizeText: Double = 18

    override func viewDidLoad() {
        super.viewDidLoad()
        myText.delegate = self
        textSizeField.delegate = self
        
        let size: Double = defaults.double(forKey: "textSize")
        if(size > 0){
            sizeText = size
            textSizeField.text = String(size)
        }
        
        
        if let colorData = defaults.data(forKey: "colorText"){
            if let color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor? {
                backgroundColor = color
                colorLabel.backgroundColor = color
            }
        }else {
            backgroundColor = UIColor.cyan
            colorLabel.backgroundColor = backgroundColor
        }
        
        if let text = defaults.string(forKey: "text") {
            myText.text = text
        }
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion =  userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //textSizeField.resignFirstResponder()
        doneButton.isEnabled = true
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            view.endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if (text == "\n") {
//            myText.resignFirstResponder()
//            return false
//        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        doneButton.isEnabled = false
        return true
    }
    
    @IBAction func startRecognition(_ sender: Any) {
        if(textSizeField.text != nil){
            if let size = Double(textSizeField.text!){
                sizeText = size
                defaults.set(size, forKey: "textSize")
            }
        }
        
        if let color = backgroundColor {
             let colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
                defaults.set(colorData, forKey: "colorText")
        }
        
        if let text = myText.text {
            defaults.set(text, forKey: "text")
        }
    }
    
    @IBAction func doneEditing(_ sender: Any) {
        doneButton.isEnabled = false
        myText.resignFirstResponder()
    }

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecognise",
            let destinationVC = segue.destination as? SpeechViewController {
            destinationVC.text = myText.text
            destinationVC.colorText = backgroundColor!
            destinationVC.textSize = Float(sizeText)
        }
    }
    
    
    @IBAction func changeColor(_ sender: UIButton) {
        backgroundColor = sender.backgroundColor
        colorLabel.backgroundColor = sender.backgroundColor
        
    }
    
    @IBAction func getTextFromID(_ sender: Any) {

        if let t = idTextField.text{
            let url = URL(string: "https://audioprompter.herokuapp.com/text?id=" + t)
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                if let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]{
                    if let t = json["text"] as? String{
                        OperationQueue.main.addOperation { [weak self] in
                            if let this = self {
                                this.myText.text = t
                            }
                        }
                    }
                    
                }
            }
            task.resume()
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textSizeField.resignFirstResponder()
        return true
    }
    
}

