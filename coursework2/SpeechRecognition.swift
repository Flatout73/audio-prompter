//
//  SpeechRecognition.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 16.03.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

protocol SpeechRecognitionClassDelegate {
    func recogniseWith(result: String)
    func underLine(fromWord: String, toWord: String, index: Int)
    func recognitionStopped(flag: Bool)
}

class SpeechRecognition: SpeechRecognitionProtocol {
    
    let mode = SpeechRecognitionMode.longDictation
    
    var delegate: SpeechRecognitionClassDelegate?
    
    lazy var micClient: MicrophoneRecognitionClient = {
        return SpeechRecognitionServiceFactory.createMicrophoneClient(.longDictation, withLanguage: "ru-RU", withKey: "eb76b0ffa0034be39981558ee48641af", with: self)
    }()
    
    var stop: Bool = true
    
    var shinglAlgo: Shingles?
    var bitapAlgo: BitapLevenshtein?
    
    init(baseText text: String) {
        shinglAlgo = Shingles(baseText: text)
        bitapAlgo = BitapLevenshtein(text: text)
    }


    func onPartialResponseReceived(_ partialResult: String!) {
        
        DispatchQueue.main.async {
            print(partialResult)
        }
        
        delegate?.recogniseWith(result: partialResult)
    }
    
    func onFinalResponseReceived(_ result: RecognitionResult!) {
    
        if(result.recognitionStatus != .recognitionSuccess) {
            print(result.recognitionStatus)
            //micClient?.endMicAndRecognition()
            micClient.audioStop()
            micClient.startMicAndRecognition()
        }
        
        //micClient?.endMicAndRecognition();
        let isFinalDicationMessage = self.mode == .longDictation &&
            (/*result.recognitionStatus == .endOfDictation ||*/
                result.recognitionStatus == .dictationEndSilenceTimeout)
        
        if(/*isFinalDicationMessage ||*/ mode == .shortPhrase || stop){
            //if let mic = micClient {
                micClient.endMicAndRecognition()
            //}
        }
        
        if(!isFinalDicationMessage){
        DispatchQueue.main.async {
            for i in 0 ..< result.recognizedPhrase.count {
                let phrase: RecognizedPhrase? = result.recognizedPhrase[i] as? RecognizedPhrase
                
                print(self.convertSpeechRecoConfidenceEnumToString(confidence: phrase!.confidence) + " " + (phrase!.inverseTextNormalizationResult))
                
                
                }
            }
            recogniseFinalWith(result: result)
        }
            
        
    }
    
    func recogniseFinalWith(result: RecognitionResult) {
        DispatchQueue.main.async { [weak self] in
            if let this = self {
                if(!result.recognizedPhrase.isEmpty){
                    if let ranges = this.shinglAlgo?.start(text: (result.recognizedPhrase[0] as! RecognizedPhrase).inverseTextNormalizationResult){
                        for range in ranges{
                            this.delegate?.underLine(fromWord: range.startWord, toWord: range.endWord, index: range.startIndex)
                        }
                    } else {
                        print("Нет совпадений по алгоритму шинглов")
                    }
                }
            }
        }
    }
    
    func convertSpeechRecoConfidenceEnumToString(confidence: Confidence) -> String {
        switch (confidence) {
        case Confidence.SpeechRecoConfidence_None:
            return "None";
            
        case Confidence.SpeechRecoConfidence_Low:
            return "Low";
            
        case .SpeechRecoConfidence_Normal:
            return "Normal";
            
        case .SpeechRecoConfidence_High:
            return "High";
        }
    }
    
    
    func onError(_ errorMessage: String!, withErrorCode errorCode: Int32) {
        print(errorMessage)
        //micClient?.startMicAndRecognition()
    }
    
    func onMicrophoneStatus(_ recording: Bool) {
        print("Microphone status changed: ", recording)
        if(!recording) {
            if(!stop){
                micClient.endMicAndRecognition()
            }
            delegate?.recognitionStopped(flag: true)
        }else {
            delegate?.recognitionStopped(flag: false)
        }
    }
    
    func onSpeakerStatus(_ speaking: Bool) {
        print(speaking)
    }
}
