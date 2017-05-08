//
//  ViewController.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 15.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var myText: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()
        myText.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            myText.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func startRecognition(_ sender: UIButton) {
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecognise",
            let destinationVC = segue.destination as? SpeechViewController {
            destinationVC.text = myText.text
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

