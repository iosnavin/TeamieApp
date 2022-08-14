//
//  ScoreBoardView.swift
//  SampleApp
//
//  Created by Naveen Reddy R on 14/08/22.
//

import Foundation
import UIKit

class ScoreBoard: UIViewController {
    var score: Int
    var wrongAnswers: Int

    lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.systemBlue
        
        return label
    }()
    
    
    lazy var newGameButton: UIButton = {
        let button = UIButton()
        button.setTitle(" New Game ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 6
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle(" Done ", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.45)
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var stackView: UIStackView = {
        var stackedInfoView = UIStackView(arrangedSubviews: [scoreLabel, wrongAnswersLabel, newGameButton, doneButton])
        stackedInfoView.axis = .vertical
        stackedInfoView.distribution = .equalSpacing
        stackedInfoView.alignment = .center
        stackedInfoView.spacing = 30.0

        return stackedInfoView
    }()
    
    
    lazy var wrongAnswersLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.red
        return label
    }()
    
    var newGameTapped: BoolBlock?
    
    init(score: Int, wrongAnswers: Int, hasNewGameTapped: @escaping BoolBlock ) {
        self.score = score
        self.wrongAnswers = wrongAnswers
        self.newGameTapped = hasNewGameTapped
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.score = 0
        self.wrongAnswers = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(stackView)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = .white
        self.scoreLabel.text = "Your score is \(score)"
        self.wrongAnswersLabel.text = "You have answered \(wrongAnswers) wrong questions"
        
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            self.stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.doneButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -32),
            self.newGameButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -32),
        ])
        
        self.newGameButton.addTarget(self, action: #selector(newGameButtonClicked), for: .touchUpInside)
        self.doneButton.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)

    }
    
    @objc func newGameButtonClicked() {
        self.newGameTapped?(true)
        self.dismiss(animated: true)
    }
    
    @objc func doneButtonClicked() {
        self.dismiss(animated: true)
    }
}



typealias BoolBlock = ((Bool) -> Void)
