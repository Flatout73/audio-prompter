//
//  Shingles.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 07.04.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation

struct Respons {
    var startWord: String
    var endWord: String
    var startIndex: Int
    var endindex: Int
    
//    init(startWord: String, endWord: String, startIndex:Int) {
//        self.startWord = startWord
//        self.endWord = endWord
//        self.startIndex = startIndex
//    }
}


class Shingles {
    
    var originalTextHashes: [String] = []
    let shinglLength = 2
    
    var canonizedWords: [String] = []
    
    var indexOfCanonizedToBase: [Int] = []
    
    
    //TODO: Добавить слова с сайта
    public static let stopWords = ["это", "как", "так", "и", "в", "над", "к", "до", "не", "на", "но", "за", "то", "с", "ли", "а", "во", "от", "со", "для", "о", "же", "ну", "вы", "бы", "что", "кто", "он", "она", "все"]
    
    init(baseText: String) {
        canonizedWords = self.canonize(text: baseText)
        originalTextHashes = hashedShinglesFrom(words: canonizedWords)
        
        let tempText = baseText.replacingOccurrences(of: "ё", with: "е")
        let tempWords = tempText
                .lowercased()
                .components(separatedBy: .punctuationCharacters)
                .joined()
                .components(separatedBy: CharacterSet(charactersIn: (" \n")))
                .filter { !$0.isEmpty }
        
        var k = 0
        for i in 0..<tempWords.count {
            if(canonizedWords[k] == tempWords[i]) {
                indexOfCanonizedToBase.insert(i, at: k)
                print(k, i)
                k += 1
            }
            
        }
        
    }
    
    func start(text: String) -> [Respons] {
        let canonized = canonize(text: text)
        let hashes = hashedShinglesFrom(words: canonized)
        //var ranges: [String: String] = [:]
        var resp = [Respons]()
        
        for i in 0..<hashes.count {
            for j in 0..<originalTextHashes.count{
                if (hashes[i] == originalTextHashes[j]) {
                    //ranges[canonizedWords[h]] = canonizedWords[h + shinglLength - 1]
                    resp.append(Respons(startWord: canonizedWords[j], endWord: canonizedWords[j + shinglLength - 1], startIndex: indexOfCanonizedToBase[j], endindex: indexOfCanonizedToBase[j + shinglLength - 1]))
                    
                }
            }
        }
        return resp
    }
    
    
    private func canonize(text: String) -> [String] {
        //let okayChars: Set<Character> = Set("")
        
        var res = text
        res = res.lowercased()
        
        res = res.replacingOccurrences(of: "ё", with: "е", options: .diacriticInsensitive, range: nil)
        return res
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: CharacterSet(charactersIn: (" \n")))
            .filter { !$0.isEmpty }
            .filter { !Shingles.stopWords.contains($0)}
    }
    
    private func hashedShinglesFrom(words: [String]) -> [String] {
        
        var shignl: [String] = []
        var hashes: [String] = []
        for i in stride(from: 0, to: (words.count-(shinglLength - 1)), by: 1) {
            shignl.removeAll()
            for j in stride(from: i, to: (i + shinglLength), by: 1) {
                shignl.append(words[j])
            }
            hashes.append(getStringHashFrom(shingle: shignl.joined(separator: " ")))
        }
        
        return hashes
    }
    
    private func MD5Hash(str: String) -> Data {
        let messageData = str.data(using: .utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }

    private func getStringHashFrom(shingle: String) -> String {
        let md5Data = MD5Hash(str: shingle)
        let MD5Hex = md5Data.map { String(format: "%02hhx", $0) }.joined()
        
        return MD5Hex
    }

}
