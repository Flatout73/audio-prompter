//
//  SpeechControllerViewController.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 22.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class SpeechViewController: UIViewController, SpeechRecognitionClassDelegate {

    @IBOutlet weak var baseText: UITextView!
    @IBOutlet weak var timer: UILabel!
    
    @IBOutlet weak var imageButton: UIButton!
    
    var text: String = "" //исходный текст
    var colorText: UIColor = UIColor.cyan
    var textSize: Float = 18
    
    var position: Int = 0 //курсор по словам
    var coursor: Int = 0 //курсор по символам
    var myMutableString: NSMutableAttributedString?
    
    
    var words: [String] = [] //words without punctuation
    var wordsWithComma: [String] = [] //words with punctuation
    
    var numberOfSymbolsToWord = [Int]()
    
    var speechRec: SpeechRecognition!
    
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.darkText,
            NSFontAttributeName: UIFont(name: "Helvetica Neue", size: CGFloat(textSize)) as Any
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
        
        wordsWithComma = text.components(separatedBy: CharacterSet(charactersIn: (" \n")))
        
        numberOfSymbolsToWord.insert(0, at: 0)
        for i in 1...wordsWithComma.count {
            numberOfSymbolsToWord.insert(numberOfSymbolsToWord[i-1] + wordsWithComma[i-1].characters.count + 1, at: i)
        }

        numberOfSymbolsToWord[numberOfSymbolsToWord.count - 1] -= 1
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        speechRec = SpeechRecognition(baseText: text)
        speechRec.delegate = self
        
        //убрать это
        //        let ranges = speechRec.shinglAlgo?.start(text: "давайте начнём")
        //            underLine(fromWord: "давайте", toWord: "начнем")
        
    }
    
    var counter = 3
    var timerC = Timer()
    @IBAction func startRecognition(_ sender: Any) {
        
        if(speechRec.stop == true){
            counter = 3
            timer.text = String(3)
            timerC = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(SpeechViewController.updateCounter), userInfo: nil, repeats: true)
            timer.isHidden = false
           
        } else {
            speechRec.stop = true
            speechRec.micClient.endMicAndRecognition()
            self.statusLabel.text = "Запись остановлена"
            self.title = "Запись остановлена"
            imageButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        }
    }
    
    func updateCounter() {
        if(counter == 0) {
            timerC.invalidate()
            self.statusLabel.text = "Идет запись..."
            self.title = "Идет запись..."
            timer.isHidden = true
            speechRec.stop = false
            imageButton.setImage(#imageLiteral(resourceName: "muted"), for: .normal)
            DispatchQueue.main.async/*After(deadline: .now() + 3.0)*/ { [weak self] in
                if let this = self{
                    let status = this.speechRec.micClient.startMicAndRecognition()
                    if(status != 0 && !this.speechRec.stop) {
                        print("Error starting audio: " + this.convertSpeechErrorToString(errorCode: status))
                        this.statusLabel.text = "Ошибка. Запись остановлена."
                        this.title = "Ошибка. Запись остановлена."
                    }
                }
            }
        } else {
            timer.text = String(counter)
            counter-=1
        }
    }

    func recogniseWith(result:String) {
        DispatchQueue.main.async { [weak self] in
            if let this = self {
                if(this.position < this.words.count){
                    let w = this.words[this.position]
                    
                    if let str = this.myMutableString {
                        
                        for res in result.components(separatedBy: " "){
                            
                            if(res.lowercased() == w) {
                                str.addAttribute(NSBackgroundColorAttributeName, value: this.colorText, range: NSRange(location: this.coursor, length: this.wordsWithComma[this.position].characters.count))
                                this.coursor += this.wordsWithComma[this.position].characters.count + 1
                                this.position += 1
                                //битап алгоритм:
                            } else if(this.coursor < this.text.characters.count && !Shingles.stopWords.contains(res) && res.characters.count > 3){
                                //запускаем битэп алгоритм с текущей позиции
                                if let index = this.speechRec.bitapAlgo?.bitapStart(pattern: res, start: this.coursor){
                                    if let indexOfWord = this.numberOfSymbolsToWord.index(of: index){
                                        //разница между текущим словом и распознанным
                                        if((indexOfWord - this.position < 5)) {
                                            this.myMutableString!.addAttribute(NSBackgroundColorAttributeName, value: this.colorText, range: NSRange(location: this.coursor, length: this.numberOfSymbolsToWord[indexOfWord + 1] - this.coursor))
                                            this.coursor = this.numberOfSymbolsToWord[indexOfWord + 1]
                                            this.position = indexOfWord + 1
                                        }
                                    }
                                }
                            }
                        }
                        
                        this.baseText.attributedText = str
                    } else {
                        print("Не удатся получить доступ к textview")
                    }
                } else {
                    print("Выход за границы текста")
                }
            }
        }
    }
    
    func underLine(fromWord: String, toWord: String, index: Int = 0) {
        if let str = self.myMutableString {
            let left = words[index..<words.count].index(of: fromWord)!
            if let right = words[left+1..<words.count].index(of: toWord) {
            
                str.addAttribute(NSBackgroundColorAttributeName, value: colorText, range: NSRange(location: numberOfSymbolsToWord[left], length: numberOfSymbolsToWord[right + 1] - numberOfSymbolsToWord[left]))
                coursor = numberOfSymbolsToWord[right+1]
                position = right + 1
            } else {
                str.addAttribute(NSBackgroundColorAttributeName, value: colorText, range: NSRange(location: numberOfSymbolsToWord[left], length: numberOfSymbolsToWord[left + 1] - numberOfSymbolsToWord[left]))
                coursor = numberOfSymbolsToWord[left+1]
                position = left + 1
            }
            baseText.attributedText = str
        }
    }
    
    func recognitionStopped(flag: Bool = true) {
        if(flag) {
            self.statusLabel.text = "Запись остановлена"
            self.title = "Запись остановлена"
        } else {
            self.statusLabel.text = "Идет запись..."
            self.title = "Идет запись..."
        }
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
        return "Unknown error: \(errorCode)"
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
