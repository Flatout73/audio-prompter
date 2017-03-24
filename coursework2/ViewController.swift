//
//  ViewController.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 15.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var myText: UITextView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func startRecognition(_ sender: UIButton) {
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRecognise",
            let destinationVC = segue.destination as? SpeechControllerViewController {
            destinationVC.text = myText.text
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

