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
    
    var numberOfSymbolsToWord = [Int]()
    
    var indexesOfSaidWords: Set<Int> = []
    
    var speechRec: SpeechRecognition?
    
    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes: [String: Any] = [
            NSForegroundColorAttributeName: UIColor.darkText,
            NSFontAttributeName: UIFont(name: "Helvetica Neue", size: CGFloat(textSize)) as Any
        ]

        text = text.replacingOccurrences(of: "\r\n", with: "\n", options: .literal, range: nil)
        
        myMutableString = NSMutableAttributedString(string: text, attributes: attributes)
        baseText.attributedText = myMutableString
        
        
        
        let wordsWithEmpty = text
                            .lowercased()
                            .replacingOccurrences(of: "ё", with: "е", options: .diacriticInsensitive, range: nil)
                            .components(separatedBy: .punctuationCharacters)
                            .joined(separator: " ")
                            .components(separatedBy: .whitespacesAndNewlines)
                            //.joined(separator: " ")
                            //.components(separatedBy: CharacterSet(charactersIn: (", .!-?\n«»\"")))
        words = wordsWithEmpty.filter { (x) -> Bool in
            !x.isEmpty
        }
        
        let wordsWithComma = text.components(separatedBy: .whitespacesAndNewlines)
        
        
//        numberOfSymbolsToWord.append(0)
//        for i in 1...wordsWithComma.count {
//            numberOfSymbolsToWord.append(numberOfSymbolsToWord.last! + wordsWithComma[i-1].characters.count + 1)
//        }
        
        var spaces = 1
        var lastNotEmpty = 0
        numberOfSymbolsToWord.append(0)
        if(wordsWithComma[0].characters.contains("-")){
            numberOfSymbolsToWord.append(0)
        }
        for i in 1...wordsWithComma.count - 1 {
            if(!wordsWithComma[i].isEmpty){
                if(!(wordsWithComma[i] == "-" || wordsWithComma[i] == "−" || wordsWithComma[i] == "–" || wordsWithComma[i] == "—")) {
                    numberOfSymbolsToWord.append(numberOfSymbolsToWord.last! + wordsWithComma[lastNotEmpty].characters.count + spaces)
                    if(wordsWithComma[i].characters.contains("-")) {
                        numberOfSymbolsToWord.append(numberOfSymbolsToWord.last!)
                        }
                    spaces = 1
                    lastNotEmpty = i
                    
                } else {
                    spaces += 2
                }
            } else {
                spaces += 1
            }
        }

        numberOfSymbolsToWord.insert(numberOfSymbolsToWord.last! + wordsWithComma.last!.characters.count, at: numberOfSymbolsToWord.count)
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        speechRec = SpeechRecognition(baseText: text)
        speechRec?.delegate = self
        
    //убрать это
            //recogniseWith(result: "Я бросил колледж после шести месяцев обучения")
        
        speechRec?.recogniseFinalWith(result: "По наивности я выбрал очень дорогой колледж")
//         speechRec?.recogniseFinalWith(result: "и все сбережения моих небогатых родителей")
//        speechRec.recogniseFinalWith(result: "решила отдать меня")
//        recogniseWith(result: "на усыновление")
//        
//        recogniseWith(result: "завораживало")
        //recogniseWith(result: "доклад")
        
        
        //        let ranges = speechRec.shinglAlgo?.start(text: "давайте начнём")
        //            underLine(fromWord: "давайте", toWord: "начнем")
        
    }
    
    var counter = 3
    var timerC = Timer()
    @IBAction func startRecognition(_ sender: Any) {
        
        if(speechRec?.stop == true){
            speechRec?.stop = false
            counter = 3
            timer.text = String(3)
            timerC = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(SpeechViewController.updateCounter), userInfo: nil, repeats: true)
            timer.isHidden = false
           
        } else {
            speechRec?.stop = true
            speechRec?.micClient.endMicAndRecognition()
            self.statusLabel.text = "Запись остановлена"
            self.title = "Запись остановлена"
            imageButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        }
    }
    
    func updateCounter() {
        counter-=1
        timer.text = String(counter)
        
        if(counter == 0) {
            timerC.invalidate()
            self.statusLabel.text = "Идет запись..."
            self.title = "Идет запись..."
            timer.isHidden = true
            speechRec?.stop = false
            imageButton.setImage(#imageLiteral(resourceName: "muted"), for: .normal)
            DispatchQueue.main.async/*After(deadline: .now() + 3.0)*/ { [weak self] in
                if let this = self{
                    if let speechRec = this.speechRec{
                    let status = speechRec.micClient.startMicAndRecognition()
                    if(status != 0 && !speechRec.stop) {
                        print("Error starting audio: " + speechRec.convertSpeechErrorToString(errorCode: status))
                        this.statusLabel.text = "Ошибка. Запись остановлена."
                        this.title = "Ошибка. Запись остановлена."
                        speechRec.stop = true
                        this.imageButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
                    }
                    }
                }
            }
        }
    }

    func recogniseWith(result:String) {
        let this = self
        
        if let str = this.myMutableString {
            
            for res in result.components(separatedBy: " "){
                if(this.position < this.words.count){
                    let w = this.words[this.position]
                    
                    if(res.lowercased() == w) {
                        print("1 by 1")
                        str.addAttribute(NSBackgroundColorAttributeName, value: this.colorText, range: NSRange(location: this.coursor, length: this.numberOfSymbolsToWord[this.position + 1] - this.coursor))
                        this.coursor = this.numberOfSymbolsToWord[this.position + 1]
                        this.position += 1
                        indexesOfSaidWords.insert(position)
                        //битап алгоритм:
                    } else if(this.coursor < this.text.characters.count && !Shingles.stopWords.contains(res) && res.characters.count > 3){
                        //запускаем битэп алгоритм с текущей позиции
                        if let index = this.speechRec?.bitapAlgo?.bitapStart(pattern: res, start: this.coursor){
                            if let indexOfWord = this.numberOfSymbolsToWord.index(of: index){
                                //разница между текущим словом и распознанным
                                if((indexOfWord - this.position < 5)) {
                                    str.addAttribute(NSBackgroundColorAttributeName, value: this.colorText, range: NSRange(location: this.coursor, length: this.numberOfSymbolsToWord[indexOfWord + 1] - this.coursor))
                                    
                                    for i in position...indexOfWord {
                                        indexesOfSaidWords.insert(i)
                                    }
                                    this.coursor = this.numberOfSymbolsToWord[indexOfWord + 1]
                                    this.position = indexOfWord + 1
                                    print("bitap", res)
                                }
                            }
                        }
                    }
                } else {
                    print("Выход за границы текста")
                }
                
                this.baseText.attributedText = str
            }
        } else {
            print("Не удатся получить доступ к textview")
        }
        
    }
    
    func handle(respons: [Respons]) {
        print("shingles")
        
        var nextPhrase = false
        var previousIndex = 0
        var isFirst = true
        
        var sortedRespons = respons.sorted{
            return $0.startIndex < $1.startIndex
        }
        var newRanges: [Respons] = sortedRespons
        
        for i in 0..<sortedRespons.count {
            if(!isFirst || sortedRespons[i].startIndex >= position) {
                if(isFirst || sortedRespons[i].startIndex - previousIndex < 3){
                    isFirst = false
                    guard let left = words[sortedRespons[i].startIndex..<words.count].index(of: sortedRespons[i].startWord), let right = words[left+1..<words.count].index(of: sortedRespons[i].endWord) else {
                        print("Не верные значения в алгоритме шинглов (слово не найдено)")
                        return
                    }
                    underLine(fromIndex: left, toIndex: right)
                    newRanges = newRanges.filter { $0.startIndex != sortedRespons[i].startIndex }
                    nextPhrase = true
                    previousIndex = right
                } else {
                    return
                }
            }
        }
        
        isFirst = true
        if(!nextPhrase) {
            for i in 0..<newRanges.count {
                if(isFirst || newRanges[i].startIndex - previousIndex < 3){
                    isFirst = false
                    guard let left = words[newRanges[i].startIndex..<words.count].index(of: newRanges[i].startWord),
                        let right = words[left+1..<words.count].index(of: newRanges[i].endWord) else {
                            print("Не верные значения в алгоритме шинглов (слово не найдено)")
                            return
                    }
                    if(!(indexesOfSaidWords.contains(left) && indexesOfSaidWords.contains(right))) {
                        underLine(fromIndex: left, toIndex: right)
                        //nextPhrase = true
                        previousIndex = right
                    }
                } else {
                    return
                }
            }
        }
    }
    
    func underLine(fromWord: String, toWord: String, index: Int = 0) {
        if let left = words[index..<words.count].index(of: fromWord){
            
            if let right = words[left+1..<words.count].index(of: toWord) {
                underLine(fromIndex: left, toIndex: right)
            } else {
                underLine(fromIndex: left, toIndex: left)
            }
        } else {
            print("Не удалось найти индекс слова для выделения!")
        }
    }
    
    func underLine(fromIndex: Int, toIndex: Int) {
        print("underline", fromIndex, toIndex)
        if let str = self.myMutableString {
            str.addAttribute(NSBackgroundColorAttributeName, value: colorText, range: NSRange(location: numberOfSymbolsToWord[fromIndex], length: numberOfSymbolsToWord[toIndex + 1] - numberOfSymbolsToWord[fromIndex]))
            coursor = numberOfSymbolsToWord[toIndex+1]
            position = toIndex + 1
            for i in fromIndex...toIndex{
                indexesOfSaidWords.insert(i)
            }
            
            baseText.attributedText = str
            
            let range = NSMakeRange(numberOfSymbolsToWord[fromIndex] - 1, 0)
            baseText.scrollRangeToVisible(range)
        }
        
    }
    
    func recognitionStopped(flag: Bool = true) {
        if(flag) {
            self.statusLabel.text = "Запись остановлена"
            self.title = "Запись остановлена"
            self.imageButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        } else {
            self.statusLabel.text = "Идет запись..."
            self.title = "Идет запись..."
        }
    }
    
    func errorShow(error: String) {
        let alert = UIAlertController(title: "Ошибка", message: "Возможно нет подключения к интернету: " + error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
