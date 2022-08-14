//
//  ViewController.swift
//  SampleApp
//
//  Created by Naveen Reddy R on 13/08/22.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var validateButton: UIButton!
    
    var pickedWords = PickWordType()
    var replaceDashesForMissingWords = [String:String]()
    private var bag = Set<AnyCancellable>()
    
    @Published var actualTags = [String]()
    @Published var answersTags = [String]()
    
    var edited = false
    var isEditingMode = true
    var tapGesture: UITapGestureRecognizer!
    var completeText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapResponse(recognizer:)))
        self.notesTextView.addGestureRecognizer(tapGesture)
        self.notesTextView.isSelectable = false
        self.notesTextView.isEditable = false
        // pickedWords = completeText.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.validateButton.isEnabled = false
        self.updateGameView()
    }
    
    func updateGameView() {
        WikiHelper().fetchRandomContent { [self] content, error in
            if error == nil {
                
                self.completeText = content
                print(content)
                
                if self.isEditingMode == false {
                    self.notesTextView.isEditable = true
                    self.notesTextView.becomeFirstResponder()
                } else {
                    let result =  getRandomNounsFromString(self.completeText)
                    pickedWords = result
                    self.actualTags = result.keys.map({$0})
                    print(self.actualTags)
                    for (index, value) in  self.pickedWords.enumerated() {
                        let key = "_____ANSWER\(index)_____"
                        self.replaceDashesForMissingWords[value.key] = key
                    }
                    
                    for key in  self.replaceDashesForMissingWords.keys {
                        let value =  self.replaceDashesForMissingWords[key]
                        DispatchQueue.main.async {
                            self.completeText =  self.completeText.replacingOccurrences(of: key, with: value!, options: .literal, range: nil)
                            self.notesTextView.text = self.completeText
                        }
                    }
                    print("tags === ")
                    print(self.replaceDashesForMissingWords)
                }
            }
        }
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        edited = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        notesTextView.textColor = UIColor.white
        textView.isEditable = false
    }
    
    //MARK: - Custom Functions
    func word(_ recognizer: UITapGestureRecognizer) {
        let location1: CGPoint = recognizer.location(in: notesTextView)
        let tapPosition: UITextPosition = notesTextView.closestPosition(to: location1)!
        //let location2: CGPoint = recognizer.location(in: notesTextView)
        guard let textRange: UITextRange = notesTextView.tokenizer.rangeEnclosingPosition(tapPosition, with: .word, inDirection:  UITextDirection(rawValue: 1)) else { return }
        let tappedWord: String = notesTextView.text(in: textRange) ?? ""
        print(tappedWord)
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        notesTextView.textColor = UIColor.red
        word(recognizer)
    }
    
    @objc func tapResponse(recognizer: UITapGestureRecognizer) {
        
        let location: CGPoint = recognizer.location(in: notesTextView)
        let tapPosition: UITextPosition = notesTextView.closestPosition(to: location)!
        guard let textRange: UITextRange = notesTextView.tokenizer.rangeEnclosingPosition(tapPosition, with: .word, inDirection: UITextDirection(rawValue: 0) ) else {return}
        let tappedWord: String = notesTextView.text(in: textRange) ?? ""
        let selectedValueWord = "_____\(tappedWord)_____"
        if replaceDashesForMissingWords.values.contains(selectedValueWord) || replaceDashesForMissingWords.keys.contains(tappedWord) {
            self.present(AnswersListView(answers: self.actualTags, answerSelected: { answerPicked  in
                DispatchQueue.main.async { [self] in
                    let replaceString = "_____\(answerPicked)_____"
                    answersTags.append(answerPicked)
                    self.completeText = self.completeText.replacingOccurrences(of:selectedValueWord, with: replaceString, options: .literal, range: nil)
                    self.view.layoutSubviews()
                    self.notesTextView.text = self.completeText
                }
            }), animated: true)
        }
        
        self.$answersTags.sink { strings in
            print(strings.count, self.actualTags.count)
            if strings.count == self.actualTags.count {
                self.validateButton.isEnabled = true
            }
        }.store(in: &bag)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func validateAnswers(_ sender: Any) {
        print(self.answersTags, self.actualTags)
        let diffIndex : [Int] = zip(self.answersTags, self.actualTags).enumerated().filter {$1.0 != $1.1}.map {$0.offset}
        print(self.actualTags.count - diffIndex.count)
        
        self.present(ScoreBoard(score: self.actualTags.count-diffIndex.count, wrongAnswers: diffIndex.count, hasNewGameTapped: { isNewGame in
            if isNewGame {
                self.actualTags = []
                self.answersTags = []
                self.updateGameView()
            }
        }), animated: true)
    }
    
    @IBAction func refreshGame() {
        self.updateGameView()
    }
    
    @IBAction func copyAllBtnTapped(_ sender: Any) {
        UIPasteboard.general.string = notesTextView?.text
    }
}

func getRandomNounsFromString(_ string: String) -> PickWordType {
    let options = NSLinguisticTagger.Options.omitWhitespace.rawValue | NSLinguisticTagger.Options.joinNames.rawValue
    let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(options))
    
    let inputString = string
    tagger.string = inputString
    
    var pick10Words = PickWordType()
    
    let totalRange = NSRange(location: 0, length: inputString.utf16.count)
    tagger.enumerateTags(in: totalRange, scheme: .nameTypeOrLexicalClass, options: NSLinguisticTagger.Options(rawValue: options)) { tag, tokenRange, sentenceRange, stop in
        guard let range = Range(tokenRange, in: inputString) else { return }
        let token = inputString[range]
        let rangeOfTag = inputString.range(of: token)
        if tag == .noun {
            print(range)
            let selectedString = String(token)
            let word = selectedString
            if pick10Words.keys.count < 10 && !pick10Words.keys.contains(word) {
                pick10Words[word] = rangeOfTag
            }
        }
    }
    return pick10Words
}

typealias PickWordType = [String: Range<String.Index>]
