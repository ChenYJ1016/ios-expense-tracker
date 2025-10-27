//
//  ExpenseDetailViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

protocol ExpenseDetailViewControllerDelegate : AnyObject{
    func didFinishEditing(expense: Expense)
}

class ExpenseDetailViewController: UITableViewController{
    weak var delegate: ExpenseDetailViewControllerDelegate?
    var expense: Expense
    var index: Int
    var allExpenses: [Expense] = []
        
    private let detailCellIdentifier = "ExpenseDetailCell"
    
    init(expense: Expense, index: Int) {
        self.index = index
        self.expense = expense
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: detailCellIdentifier)
                
        self.setupNavigationBar()
    }
    
    // MARK: Helper methods
    private func setupNavigationBar(){
        
        title = "Your expense"

        // add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editCurrentExpense))

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // return section num as needed
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
            case 0:
                return 3
            case 1:
                return 1
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
            case 0:
                return "Details"
            case 1:
                return "Amount"
            default:
                return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
            // tuple switching
            switch (indexPath.section, indexPath.row){
            case (0, 0):
                content.text = "Name"
                content.secondaryText = expense.name
            case (0, 1):
                content.text = "Date"
                content.secondaryText = expense.date.formatted(date: .numeric, time: .omitted)

            case (0, 2):
                content.text = "Expense Type"
                content.secondaryText = expense.type.rawValue
            case (1, 0):
                content.text = "Amount"
                content.secondaryText = CurrencyFormatter.shared.string(from: expense.amount)
                content.secondaryTextProperties.font = .boldSystemFont(ofSize: 17)
                content.secondaryTextProperties.color = .label
            default:
                break
        }
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
    
    @objc private func editCurrentExpense(){
        // present edit expense data modal
        let editVC = ExpenseFormController()
        editVC.delegate = self
        editVC.expense = self.expense
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
}

extension ExpenseDetailViewController: ExpenseFormControllerDelegate{
    func didUpdateExpense(_ expense: Expense) {
        self.expense = expense
        delegate?.didFinishEditing(expense: expense)
        tableView.reloadData()
    }
}

