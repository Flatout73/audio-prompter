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
    func recognitionStopped()
}

class SpeechRecognition: SpeechRecognitionProtocol {
    
    var delegate: SpeechRecognitionClassDelegate?
    
    var micClient: MicrophoneRecognitionClient?
    var mode: SpeechRecognitionMode
    
    var stop: Bool = false
    
    var shinglAlgo: Shingles?
    
    init(mode: SpeechRecognitionMode) {
        self.mode = mode
    }

    func onPartialResponseReceived(_ partialResult: String!) {
        
        print(partialResult)
        delegate?.recogniseWith(result: partialResult)
    }
    
    func onFinalResponseReceived(_ result: RecognitionResult!) {
    
        if(result.recognitionStatus != .recognitionSuccess) {
            print(result.recognitionStatus)
            //micClient?.endMicAndRecognition()
            micClient?.audioStop()
            micClient?.startMicAndRecognition()
        }
        
        //micClient?.endMicAndRecognition();
        let isFinalDicationMessage = self.mode == .longDictation &&
            (/*result.recognitionStatus == .endOfDictation ||*/
                result.recognitionStatus == .dictationEndSilenceTimeout)
        
        if(/*isFinalDicationMessage ||*/ mode == .shortPhrase || stop){
            if let mic = micClient {
                mic.endMicAndRecognition()
            }
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
                        this.delegate?.underLine(fromWord: ranges.startWord, toWord: ranges.endWord, index: ranges.startIndex)
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
            micClient?.endMicAndRecognition()
            delegate?.recognitionStopped()
            
        }
    }
    
    func onSpeakerStatus(_ speaking: Bool) {
        print(speaking)
    }
}
