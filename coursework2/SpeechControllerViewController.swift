//
//  SpeechControllerViewController.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 22.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class SpeechControllerViewController: UIViewController, SpeechRecognitionClassDelegate {
    
    var micClient:  MicrophoneRecognitionClient?;
    var mode: SpeechRecognitionMode = SpeechRecognitionMode.longDictation

    @IBOutlet weak var baseText: UITextView!
    
    var text: String = ""
    
    var k: Int = 0 //курсор
    var myMutableString: NSMutableAttributedString?
    
    
    var words: [String] = [] //words without punctuation
    var wordsWithComma: [String] = [] //words with punctuation
    
    var numberOfSymbolsToWord = [Int]()
    
    var speechRec: SpeechRecognition!
    
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [
            NSForegroundColorAttributeName: UIColor.darkText,
            NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 18.0)
        ]
        myMutableString = NSMutableAttributedString(string: text, attributes: attributes)
        baseText.attributedText = myMutableString
        
        let wordsWithEmpty = text
                            .lowercased()
                            .replacingOccurrences(of: "ё", with: "е", options: .diacriticInsensitive, range: nil)
                            .components(separatedBy: CharacterSet(charactersIn: (", .!-?\n")))
        words = wordsWithEmpty.filter { (x) -> Bool in
            !x.isEmpty
        }
        
        //words = canonize(text: text)
        wordsWithComma = text.components(separatedBy: CharacterSet(charactersIn: (" \n")))
        
        numberOfSymbolsToWord.insert(0, at: 0)
        for i in 1...wordsWithComma.count {
            //numberOfSymbolsToWord[i] = wordsWithComma[i-1].characters.count + 1
            numberOfSymbolsToWord.insert(numberOfSymbolsToWord[i-1] + wordsWithComma[i-1].characters.count + 1, at: i)
        }

        numberOfSymbolsToWord[numberOfSymbolsToWord.count - 1] -= 1
        
    }
    
    
    @IBAction func startRecognition(_ sender: Any) {
        self.statusLabel.text = "Идет запись..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if let this = self{
                let status = this.micClient?.startMicAndRecognition()
                if(status != 0 && !this.speechRec.stop) {
                    print("Error starting audio: " + this.convertSpeechErrorToString(errorCode: status!))
                    this.statusLabel.text = "Ошибка. Запись остановлена."
                }
            }
        }
    }
    
    @IBAction func stopRecognition(_ sender: Any) {
        speechRec.stop = true
        micClient?.endMicAndRecognition()
        self.statusLabel.text = "Запись остановлена."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        speechRec = SpeechRecognition(mode: mode)
        speechRec.shinglAlgo = Shingles(baseText: text)
        //shinglAlgo?.start(text: text)
        
         //убрать это
//        let ranges = shinglAlgo?.start(text: "давайте начнём")
//        for (start, end) in ranges! {
//            underLine(fromWord: start, toWord: end)
//        }
        
        micClient = SpeechRecognitionServiceFactory.createMicrophoneClient(mode, withLanguage: "ru-ru", withKey: "eb76b0ffa0034be39981558ee48641af", with: speechRec)
        
        if let mic = micClient {
            //let status = mic.startMicAndRecognition();
            speechRec.micClient = mic
            speechRec.delegate = self
//            if(status != 0) {
//                print("Error starting audio: " + convertSpeechErrorToString(errorCode: status))
//            }
        }
        
        
    }
    
    var coursor: Int = 0
    func recogniseWith(result:String) {
    DispatchQueue.main.async {

        if(self.k < self.words.count){
            let w = self.words[self.k]
       
            if let str = self.myMutableString {
            
            for res in result.components(separatedBy: " "){
                
                if(res.lowercased() == w) {
                    str.addAttribute(NSBackgroundColorAttributeName, value: UIColor.cyan, range: NSRange(location: self.coursor, length: self.wordsWithComma[self.k].characters.count))
                    self.coursor += self.wordsWithComma[self.k].characters.count + 1
                    self.k += 1
                }
                }
        
                self.baseText.attributedText = str
            } else {
            return
            }
        } else {
            return
        }
        }
    }
    
    func underLine(fromWord: String, toWord: String, index: Int = 0) {
        if let str = self.myMutableString {
            let left = words[index..<words.count].index(of: fromWord)!
            if let right = words[left+1..<words.count].index(of: toWord) {
            
                str.addAttribute(NSBackgroundColorAttributeName, value: UIColor.cyan, range: NSRange(location: numberOfSymbolsToWord[left], length: numberOfSymbolsToWord[right + 1] - numberOfSymbolsToWord[left]))
                coursor = numberOfSymbolsToWord[right+1]
                k = right + 1
            } else {
                str.addAttribute(NSBackgroundColorAttributeName, value: UIColor.cyan, range: NSRange(location: numberOfSymbolsToWord[left], length: numberOfSymbolsToWord[left + 1] - numberOfSymbolsToWord[left]))
                coursor = numberOfSymbolsToWord[left+1]
                k = left + 1
            }
            baseText.attributedText = str
        }
    }
    
    func recognitionStopped() {
        self.statusLabel.text = "Запись остановлена."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func convertSpeechErrorToString(errorCode: OSStatus) -> String {
        switch (SpeechClientStatus(rawValue: errorCode)!) {
        case .securityFailed:         return "SpeechClientStatus_SecurityFailed"
        case .loginFailed:            return "SpeechClientStatus_LoginFailed"
        case .timeout:                return "SpeechClientStatus_Timeout"
        case .connectionFailed:       return "SpeechClientStatus_ConnectionFailed"
        case .nameNotFound:           return "SpeechClientStatus_NameNotFound"
        case .invalidService:         return "SpeechClientStatus_InvalidService"
        case .invalidProxy:           return "SpeechClientStatus_InvalidProxy"
        case .badResponse:            return "SpeechClientStatus_BadResponse"
        case .internalError:          return "SpeechClientStatus_InternalError"
        case .authenticationError:    return "SpeechClientStatus_AuthenticationError"
        case .authenticationExpired:  return "SpeechClientStatus_AuthenticationExpired"
        case .limitsExceeded:         return "SpeechClientStatus_LimitsExceeded"
        case .audioOutputFailed:      return "SpeechClientStatus_AudioOutputFailed"
        case .microphoneInUse:        return "SpeechClientStatus_MicrophoneInUse"
        case .microphoneUnavailable:  return "SpeechClientStatus_MicrophoneUnavailable"
        case .microphoneStatusUnknown:return "SpeechClientStatus_MicrophoneStatusUnknown"
        case .invalidArgument:        return "SpeechClientStatus_InvalidArgument"
        }
        return "Unknow error: \(errorCode)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
