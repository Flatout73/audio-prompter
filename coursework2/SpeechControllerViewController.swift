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

    @IBOutlet weak var baseText: UILabel!
    
    var text: String = ""
    
    var k: Int = 0
    var myMutableString: NSMutableAttributedString?
    var words: [String] = []
    var wordsWithComma: [String] = []
    
    var speechRec: SpeechRecognition!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [
            NSForegroundColorAttributeName: UIColor.red
        ]
        myMutableString = NSMutableAttributedString(string: text, attributes: attributes)
        baseText.attributedText = myMutableString
        //words = text.components(separatedBy: " ")
        let wordsWithEmpty = text.components(separatedBy: CharacterSet(charactersIn: (", .?\n")))
        words = wordsWithEmpty.filter { (x) -> Bool in
            !x.isEmpty
        }
        
        wordsWithComma = text.components(separatedBy: " ")
    }
    
    
    @IBAction func stopRecognition(_ sender: Any) {
        speechRec.stop = true
        micClient?.endMicAndRecognition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        speechRec = SpeechRecognition(mode: mode)
        
        micClient = SpeechRecognitionServiceFactory.createMicrophoneClient(mode, withLanguage: "ru-ru", withKey: "eb76b0ffa0034be39981558ee48641af", with: speechRec)
        
        if let mic = micClient {
            let status = mic.startMicAndRecognition();
            speechRec.micClient = mic
            speechRec.delegate = self
            if(status != 0) {
                print("Error starting audio: " + convertSpeechErrorToString(errorCode: status))
            }
        }
    }
    
    var coursor: Int = 0
    func recogniseWith(result:String) {
    DispatchQueue.main.async {

        if(self.k < self.words.count){
            var w = self.words[self.k]
       
            if let str = self.myMutableString {
            
            for res in result.components(separatedBy: " "){
                
                if(res.lowercased() == w.lowercased()) {
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
