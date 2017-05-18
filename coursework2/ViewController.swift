//
//  ViewController.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 15.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var myText: UITextView!
    @IBOutlet weak var textSizeField: UITextField!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var picker: UIPickerView!
    
    var backgroundColor: UIColor?
    let defaults = UserDefaults.standard
    var sizeText: Double = 18

    let languages = ["English", "Русский"]
    
    var numberOfLang = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myText.delegate = self
        textSizeField.delegate = self
        idTextField.delegate = self
        
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
    
        indicator.hidesWhenStopped = true
        
        picker.delegate = self
        
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

        defaults.set(sizeText, forKey: "textSize")
        
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
            if(textSizeField.text != nil){
                if let size = Double(textSizeField.text!){
                    sizeText = size
                }
            }
            destinationVC.textSize = Float(sizeText)
            destinationVC.lang = numberOfLang
        }
    }
    
    
    @IBAction func changeColor(_ sender: UIButton) {
        backgroundColor = sender.backgroundColor
        colorLabel.backgroundColor = sender.backgroundColor
        
    }
    
    @IBAction func getTextFromID(_ sender: Any) {
        
        indicator.startAnimating()

        if let tf = idTextField.text{
            let url = URL(string: "https://audioprompter.herokuapp.com/text?id=" + tf)
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                guard error == nil else {
                    print(error!)
                    OperationQueue.main.addOperation { [weak self] in
                        if let this = self {
                            let alert = UIAlertController(title: "Ошибка", message: "Скорее всего, нет подключения к интернету", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            this.present(alert, animated: true) {
                                this.indicator.stopAnimating()
                            }
                        }
                    }
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
                    let t = json?["text"] as? String else {
                        OperationQueue.main.addOperation { [weak self] in
                            if let this = self {
                                let alert = UIAlertController(title: "Ошибка", message: "Нет текста с таким ID", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                this.present(alert, animated: true) {
                                    this.indicator.stopAnimating()
                                }
                            }
                        }
                        return
                }
                
                OperationQueue.main.addOperation { [weak self] in
                    if let this = self {
                        this.myText.text = t
                        this.indicator.stopAnimating()
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
        textField.resignFirstResponder()
        if(textField == idTextField) {
            getTextFromID(textField)
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberOfLang = row
    }
}

