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

}


class Shingles {
    
    var originalTextHashes: [String] = []
    let shinglLength = 3
    
    var canonizedWords: [String] = []
    
    var indexOfCanonizedToBase: [Int] = []
    
    init(baseText: String, language: Int = 1) {
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
        
        if(language == 1) {
            Shingles.stopWords = Shingles.russianStopWords
        } else{
            Shingles.stopWords = Shingles.englishStopWords
        }
        
    }
    
    func start(text: String) -> [Respons] {
        let canonized = canonize(text: text)
        let hashes = hashedShinglesFrom(words: canonized)
        var resp = [Respons]()
        
        for i in 0..<hashes.count {
            for j in 0..<originalTextHashes.count{
                if (hashes[i] == originalTextHashes[j]) {
                    resp.append(Respons(startWord: canonizedWords[j], endWord: canonizedWords[j + shinglLength - 1], startIndex: indexOfCanonizedToBase[j], endindex: indexOfCanonizedToBase[j + shinglLength - 1]))
                    print("Shingles", resp.last!.startWord, resp.last!.endWord)
                    
                }
            }
        }
        return resp
    }
    
    
    private func canonize(text: String) -> [String] {
        
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
    
        public static var stopWords = Shingles.russianStopWords
            
            
        private static let russianStopWords = ["а",	"год",	"т", "е",	"говорил",	"у", "и",	"говорит",	"я", "ж",	"года",	"та", "м",	"году",	"те", "о",	"где",	"уж", "на",	"да",	"со", "не",	"ее",	"то", "ни",	"за",	"том", "об",	"из",	"снова", "но",	"ли",	"тому", "он",	"же",	"совсем", "мне",	"им",	"того", "мои",	"до",	"тогда", "мож",	"по",	"тоже", "она",	"ими",	"собой", "они",	"под",	"тобой", "оно",	"иногда",	"собою", "мной",	"довольно",	"тобою", "много",	"именно",	"сначала", "многочисленное",	"долго",	"только", "многочисленная",	"позже",	"уметь", "многочисленные",	"более",	"тот", "многочисленный",	"должно",	"тою", "мною",	"пожалуйста",	"хорошо", "мой",	"значит",	"хотеть", "мог",	"иметь",	"хочешь", "могут",	"больше",	"хоть", "можно",	"пока",	"хотя", "может",	"ему",	"свое", "можхо",	"имя",	"свои", "мор",	"пор",	"твой", "моя",	"пора",	"своей", "моё",	"потом",	"своего", "мочь",	"потому",	"своих", "над",	"после",	"свою", "нее",	"почему",	"твоя", "оба",	"почти",	"твоё", "нам",	"посреди",	"раз", "нем",	"ей",	"уже", "нами",	"два",	"сам", "ними",	"две",	"там", "мимо",	"двенадцать",	"тем", "немного",	"двенадцатый",	"чем", "одной",	"двадцать",	"сама", "одного",	"двадцатый",	"сами", "менее",	"двух",	"теми", "однажды",	"его",	"само", "однако",	"дел",	"рано", "меня",	"или",	"самом", "нему",	"без",	"самому", "меньше",	"день",	"самой", "ней",	"занят",	"самого", "наверху",	"занята",	"семнадцать", "него",	"занято",	"семнадцатый", "ниже",	"заняты",	"самим", "мало",	"действительно",	"самими", "надо",	"давно",	"самих", "один",	"девятнадцать",	"саму", "одиннадцать",	"девятнадцатый",	"семь", "одиннадцатый",	"девять",	"чему", "назад",	"девятый",	"раньше", "наиболее",	"даже",	"сейчас", "недавно",	"алло",	"чего", "миллионов",	"жизнь",	"сегодня", "недалеко",	"далеко",	"себе", "между",	"близко",	"тебе", "низко",	"здесь",	"сеаой", "меля",	"дальше",	"человек", "нельзя",	"для",	"разве", "нибудь",	"лет",	"теперь", "непрерывно",	"зато",	"себя", "наконец",	"даром",	"тебя", "никогда",	"первый",	"седьмой", "никуда",	"перед",	"спасибо", "нас",	"затем",	"слишком", "наш",	"зачем",	"так", "нет",	"лишь",	"такое", "нею",	"десять",	"такой", "неё",	"десятый",	"такие", "них",	"ею",	"также", "мира",	"её",	"такая", "наша",	"их",	"сих", "наше",	"бы",	"тех", "наши",	"еще",	"чаще", "ничего",	"при",	"четвертый", "начала",	"был",	"через", "нередко",	"про",	"часто", "несколько",	"процентов",	"шестой", "обычно",	"против",	"шестнадцать", "опять",	"просто",	"шестнадцатый", "около",	"бывает",	"шесть", "мы",	"бывь",	"четыре", "ну",	"если",	"четырнадцать", "нх",	"люди",	"четырнадцатый", "от",	"была",	"сколько", "отовсюду",	"были",	"сказал", "особенно",	"было",	"сказала", "нужно",	"будем",	"сказать", "очень",	"будет",	"ту", "отсюда",	"будете",	"ты", "в",	"будешь",	"три", "во",	"прекрасно",	"эта", "вон",	"буду",	"эти", "вниз",	"будь",	"что", "внизу",	"будто",	"это", "вокруг",	"будут",	"чтоб", "вот",	"ещё",	"этом", "восемнадцать",	"пятнадцать",	"этому", "восемнадцатый",	"пятнадцатый",	"этой", "восемь",	"друго",	"этого", "восьмой",	"другое",	"чтобы", "вверх",	"другой",	"этот", "вам",	"другие",	"стал", "вами",	"другая",	"туда", "важное",	"других",	"этим", "важная",	"есть",	"этими", "важные",	"пять",	"рядом", "важный",	"быть",	"тринадцать", "вдали",	"лучше",	"тринадцатый", "везде",	"пятый",	"этих", "ведь",	"к",	"третий", "вас",	"ком",	"тут", "ваш",	"конечно",	"эту", "ваша",	"кому",	"суть", "ваше",	"кого",	"чуть", "ваши",	"когда",	"тысяч", "впрочем",	"которой", "весь",	"которого", "вдруг",	"которая", "вы",	"которые", "все",	"который", "второй",	"которых", "всем",	"кем", "всеми",	"каждое", "времени",	"каждая", "время",	"каждые", "всему",	"каждый", "всего",	"кажется", "всегда",	"как", "всех",	"какой", "всею",	"какая", "всю",	"кто", "вся",	"кроме", "всё",	"куда", "всюду",	"кругом", "г",	"с"]
    
    private static let englishStopWords = [ "a", "about", "above", "after", "again", "against", "all", "am", "an",
                                            "and", "any", "are", "aren't", "as", "at", "be", "because", "been", "before", "being",
                                            "below", "between", "both", "but", "by", "can't", "cannot", "could", "couldn't", "did", "didn't", "do", "does", "doesn't", "doing", "don't", "down","during", "each", "few", "for", "from", "further", "had", "hadn't", "has", "hasn't", "have", "haven't", "having", "he", "he'd", "he'll", "he's", "her", "here", "here's", "hers", "herself", "him", "himself", "his", "how", "how's", "i", "i'd", "i'll", "i'm", "i've", "if", "in", "into", "is", "isn't", "it", "it's", "its", "itself", "let's", "me", "more", "most", "mustn't", "my", "myself", "no", "nor", "not", "of", "off", "on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves", "out", "over", "own", "same", "shan't", "she", "she'd", "she'll", "she's", "should", "shouldn't", "so", "some", "such", "than", "that", "that's", "the", "their", "theirs", "them", "themselves", "then", "there", "there's", "these", "they", "they'd", "they'll", "they're", "they've", "this", "those", "through", "to", "too", "under", "until", "up", "very", "was", "wasn't", "we", "we'd", "we'll", "we're", "we've", "were", "weren't", "what", "what's", "when", "when's", "where", "where's", "which", "while", "who", "who's", "whom", "why", "why's", "with", "won't", "would", "wouldn't", "you", "you'd", "you'll", "you're", "you've", "your", "yours", "yourself","yourselves" ]

}
