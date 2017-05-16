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
    let shinglLength = 4
    
    var canonizedWords: [String] = []
    
    var indexOfCanonizedToBase: [Int] = []
    
    init(baseText: String) {
        canonizedWords = self.canonize(text: baseText)
        originalTextHashes = hashedShinglesFrom(words: canonizedWords)
        
        let tempText = baseText.replacingOccurrences(of: "ё", with: "е")
        let tempWords = tempText
                .lowercased()
                .components(separatedBy: .punctuationCharacters)
                .joined(separator: " ")
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { !$0.isEmpty }
        
        var k = 0
        for i in 0..<tempWords.count {
            if(canonizedWords[k] == tempWords[i]) {
                indexOfCanonizedToBase.insert(i, at: k)
                //print(k, i)
                k += 1
            }
            
            if(k == canonizedWords.count) {
                break
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
                    print("Shingles", resp.last!.startWord, resp.last!.endWord)
                    
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
            .joined(separator: " ")
            .components(separatedBy: .whitespacesAndNewlines)
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
    
        public static let stopWords = ["а",	"год",	"т", "е",	"говорил",	"у", "и",	"говорит",	"я", "ж",	"года",	"та", "м",	"году",	"те", "о",	"где",	"уж", "на",	"да",	"со", "не",	"ее",	"то", "ни",	"за",	"том", "об",	"из",	"снова", "но",	"ли",	"тому", "он",	"же",	"совсем", "мне",	"им",	"того", "мои",	"до",	"тогда", "мож",	"по",	"тоже", "она",	"ими",	"собой", "они",	"под",	"тобой", "оно",	"иногда",	"собою", "мной",	"довольно",	"тобою", "много",	"именно",	"сначала", "многочисленное",	"долго",	"только", "многочисленная",	"позже",	"уметь", "многочисленные",	"более",	"тот", "многочисленный",	"должно",	"тою", "мною",	"пожалуйста",	"хорошо", "мой",	"значит",	"хотеть", "мог",	"иметь",	"хочешь", "могут",	"больше",	"хоть", "можно",	"пока",	"хотя", "может",	"ему",	"свое", "можхо",	"имя",	"свои", "мор",	"пор",	"твой", "моя",	"пора",	"своей", "моё",	"потом",	"своего", "мочь",	"потому",	"своих", "над",	"после",	"свою", "нее",	"почему",	"твоя", "оба",	"почти",	"твоё", "нам",	"посреди",	"раз", "нем",	"ей",	"уже", "нами",	"два",	"сам", "ними",	"две",	"там", "мимо",	"двенадцать",	"тем", "немного",	"двенадцатый",	"чем", "одной",	"двадцать",	"сама", "одного",	"двадцатый",	"сами", "менее",	"двух",	"теми", "однажды",	"его",	"само", "однако",	"дел",	"рано", "меня",	"или",	"самом", "нему",	"без",	"самому", "меньше",	"день",	"самой", "ней",	"занят",	"самого", "наверху",	"занята",	"семнадцать", "него",	"занято",	"семнадцатый", "ниже",	"заняты",	"самим", "мало",	"действительно",	"самими", "надо",	"давно",	"самих", "один",	"девятнадцать",	"саму", "одиннадцать",	"девятнадцатый",	"семь", "одиннадцатый",	"девять",	"чему", "назад",	"девятый",	"раньше", "наиболее",	"даже",	"сейчас", "недавно",	"алло",	"чего", "миллионов",	"жизнь",	"сегодня", "недалеко",	"далеко",	"себе", "между",	"близко",	"тебе", "низко",	"здесь",	"сеаой", "меля",	"дальше",	"человек", "нельзя",	"для",	"разве", "нибудь",	"лет",	"теперь", "непрерывно",	"зато",	"себя", "наконец",	"даром",	"тебя", "никогда",	"первый",	"седьмой", "никуда",	"перед",	"спасибо", "нас",	"затем",	"слишком", "наш",	"зачем",	"так", "нет",	"лишь",	"такое", "нею",	"десять",	"такой", "неё",	"десятый",	"такие", "них",	"ею",	"также", "мира",	"её",	"такая", "наша",	"их",	"сих", "наше",	"бы",	"тех", "наши",	"еще",	"чаще", "ничего",	"при",	"четвертый", "начала",	"был",	"через", "нередко",	"про",	"часто", "несколько",	"процентов",	"шестой", "обычно",	"против",	"шестнадцать", "опять",	"просто",	"шестнадцатый", "около",	"бывает",	"шесть", "мы",	"бывь",	"четыре", "ну",	"если",	"четырнадцать", "нх",	"люди",	"четырнадцатый", "от",	"была",	"сколько", "отовсюду",	"были",	"сказал", "особенно",	"было",	"сказала", "нужно",	"будем",	"сказать", "очень",	"будет",	"ту", "отсюда",	"будете",	"ты", "в",	"будешь",	"три", "во",	"прекрасно",	"эта", "вон",	"буду",	"эти", "вниз",	"будь",	"что", "внизу",	"будто",	"это", "вокруг",	"будут",	"чтоб", "вот",	"ещё",	"этом", "восемнадцать",	"пятнадцать",	"этому", "восемнадцатый",	"пятнадцатый",	"этой", "восемь",	"друго",	"этого", "восьмой",	"другое",	"чтобы", "вверх",	"другой",	"этот", "вам",	"другие",	"стал", "вами",	"другая",	"туда", "важное",	"других",	"этим", "важная",	"есть",	"этими", "важные",	"пять",	"рядом", "важный",	"быть",	"тринадцать", "вдали",	"лучше",	"тринадцатый", "везде",	"пятый",	"этих", "ведь",	"к",	"третий", "вас",	"ком",	"тут", "ваш",	"конечно",	"эту", "ваша",	"кому",	"суть", "ваше",	"кого",	"чуть", "ваши",	"когда",	"тысяч", "впрочем",	"которой", "весь",	"которого", "вдруг",	"которая", "вы",	"которые", "все",	"который", "второй",	"которых", "всем",	"кем", "всеми",	"каждое", "времени",	"каждая", "время",	"каждые", "всему",	"каждый", "всего",	"кажется", "всегда",	"как", "всех",	"какой", "всею",	"какая", "всю",	"кто", "вся",	"кроме", "всё",	"куда", "всюду",	"кругом", "г",	"с"]

}
