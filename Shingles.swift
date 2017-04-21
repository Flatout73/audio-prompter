//
//  Shingles.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 07.04.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation

class Shingles {
    
    var originalTextHashes: [String] = []
    let shinglLength = 2
    
    var canonizedWords: [String] = []
    
    init(baseText: String) {
        canonizedWords = self.canonize(text: baseText)
        originalTextHashes = hashedShinglesFrom(words: canonizedWords)
        
    }
    
    func start(text: String) -> [String:String] {
        let canonized = canonize(text: text)
        let hashes = hashedShinglesFrom(words: canonized)
        var ranges: [String: String] = [:]
        
        for i in 0..<hashes.count {
            if let h = originalTextHashes.index(of: hashes[i]) {
                ranges[canonizedWords[h]] = canonizedWords[h + shinglLength - 1]
            }
        }
        return ranges
    }
    
    
    private func canonize(text: String) -> [String] {
        //let okayChars: Set<Character> = Set("")
        
        let stopWords = ["это", "как", "так", "и", "в", "над", "к", "до", "не", "на", "но", "за", "то", "с", "ли", "а", "во", "от", "со", "для", "о", "же", "ну", "вы", "бы", "что", "кто", "он", "она"]
        
        var res = text
        res = res.lowercased()
        //        for sWord in stopWords {
        //            res = res.replacingOccurrences(of: sWord, with: "", options: .diacriticInsensitive, range: nil)
        //        }
        
        res = res.replacingOccurrences(of: "ё", with: "е", options: .diacriticInsensitive, range: nil)
        return res
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: CharacterSet(charactersIn: (" \n")))
            .filter { !$0.isEmpty }
            .filter { !stopWords.contains($0)}
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
