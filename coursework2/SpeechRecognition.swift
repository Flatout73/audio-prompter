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
    func handle(respons: [Respons])
    func underLine(fromWord: String, toWord: String, index: Int)
    func recognitionStopped(flag: Bool)
    func errorShow(error: String)
}

class SpeechRecognition: SpeechRecognitionProtocol {
    
    let mode = SpeechRecognitionMode.longDictation
    
    var delegate: SpeechRecognitionClassDelegate?
    
    lazy var micClient: MicrophoneRecognitionClient = {
        return SpeechRecognitionServiceFactory.createMicrophoneClient(.longDictation, withLanguage: "ru-RU", withKey: "eb76b0ffa0034be39981558ee48641af", with: self)
    }()
    
    var stop: Bool = true
    
    var shinglAlgo: Shingles?
    var bitapAlgo: BitapHamming?
    
    init(baseText text: String) {
        shinglAlgo = Shingles(baseText: text)
        bitapAlgo = BitapHamming(text: text)
    }


    func onPartialResponseReceived(_ partialResult: String!) {
        
        DispatchQueue.main.async { [weak self] in
            if let this = self {
                print(partialResult)
                this.delegate?.recogniseWith(result: partialResult)
            }
        }
        
        
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
            DispatchQueue.main.async { [weak self] in
                if let this = self {
                    for i in 0 ..< result.recognizedPhrase.count {
                        let phrase: RecognizedPhrase? = result.recognizedPhrase[i] as? RecognizedPhrase
                        
                        print(this.convertSpeechRecoConfidenceEnumToString(confidence: phrase!.confidence) + " " + (phrase!.inverseTextNormalizationResult))
                        
                        this.recogniseFinalWith(result: phrase!.inverseTextNormalizationResult)
                        
                    }
                }
            }
            
        }
        
        
    }
    
    func recogniseFinalWith(result: String) {
        //DispatchQueue.main.async { [weak self] in
            //let this = self
                if(!result.isEmpty){
                    if let ranges = shinglAlgo?.start(text: result){
//                        for range in ranges{
//                            delegate?.underLine(fromWord: range.startWord, toWord: range.endWord, index: range.startIndex)
//                        }
                        delegate?.handle(respons: ranges)
                    } else {
                        print("Нет совпадений по алгоритму шинглов")
                    }
                }
        
        //}
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
        DispatchQueue.main.async { [weak self] in
            if let this = self {
                print(errorMessage, this.convertSpeechErrorToString(errorCode: errorCode))
                this.micClient.audioStop()
                this.delegate?.errorShow(error: errorMessage)
                
            //self.micClient.endMicAndRecognition()
            }
        }
    }
    
    func onMicrophoneStatus(_ recording: Bool) {
        print("Microphone status changed: ", recording)
        if(!recording) {
            if(!stop){
                micClient.endMicAndRecognition()
                stop = true
            }
            delegate?.recognitionStopped(flag: true)
        }else {
            delegate?.recognitionStopped(flag: false)
        }
    }
//    
//    func onSpeakerStatus(_ speaking: Bool) {
//        print(speaking)
//    }
    
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
}
