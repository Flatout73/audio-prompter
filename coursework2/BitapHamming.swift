//
//  BitapLevenshtein.swift
//  coursework2
//
//  Created by Леонид Лядвейкин on 08.05.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation

class BitapHamming {
    var baseText:String
    let k = 2 //расстояние левенштейна(Хемминга)
    
    init(text: String) {
        self.baseText = text
    }

    //можно попробовать возвращать nil в случае неуспеха
    func bitapStart(pattern: String, start: Int = 0) -> Int{
        var result = -1
        let m = pattern.characters.count
        var patternMask = [Int]()
        
        if(m > 31) {
            print("Pattern too long")
            return -1
        }
        var R = [Int]()
        
        for i in 0...k {
            R.insert(~1, at: i)
        }
        
        for i in 0...10000 {
            patternMask.insert(~0, at: i)
        }
        
        var t = 0
        for i in pattern.characters {
            patternMask[i.unicodeScalarCodePoint()] &= ~(1 << t)
            t += 1
        }
        
        t = 0
        for c in baseText.substring(from: baseText.index(baseText.startIndex, offsetBy:start)).characters{
            
            var oldRd1 = R[0]
            R[0] |= patternMask[c.unicodeScalarCodePoint()]
            
            R[0] <<= 1
            
            for d in 1...k {
                let tmp = R[d]
                R[d] = (oldRd1 & (R[d] | patternMask[c.unicodeScalarCodePoint()])) << 1
                oldRd1 = tmp
            }
            
            if(0 == (R[k] & (1 << m))) {
                result = (t - m) + 1 + start
                break
            }
            
            t += 1
        }
        
        return result
    }
}

extension Character
{
    func unicodeScalarCodePoint() -> Int
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return Int(scalars[scalars.startIndex].value)
    }
}
