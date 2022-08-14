//
//  AnswersListView.swift
//  SampleApp
//
//  Created by Naveen Reddy R on 14/08/22.
//

import Foundation
import UIKit

typealias AnswerSelectedBlock = (String) -> Void
class AnswersListView: UIViewController {
    
    private
    var answers : [String]
    
    private
    var answerSelected : AnswerSelectedBlock?
    
    
    lazy var tableList: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(Cell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // TODO: incorrect init
    init(answers: [String], answerSelected: @escaping AnswerSelectedBlock) {
        self.answers = answers
        super.init(nibName: nil, bundle: nil)
        self.answerSelected = answerSelected
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.answers = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableList.delegate = self
        tableList.dataSource = self
        self.answers.shuffle()
        self.view.addSubview(tableList)
        tableList.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.tableList.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableList.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableList.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.tableList.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            
        ])
    }
}

extension AnswersListView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Cell
        cell.textLabel?.text = self.answers[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        self.answerSelected?(self.answers[indexPath.row])
        self.dismiss(animated: true)
    }
}




// MARK: TableViewCell 

class Cell: UITableViewCell {
    
}

