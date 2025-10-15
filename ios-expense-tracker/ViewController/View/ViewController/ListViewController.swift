//
//  ViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

class ListViewController: UIViewController {
    
    
    
    // MARK: properties
//    var allExpenses: [Expense] = [
//        Expense(name: "Lunch", date: DateComponents(year: 2025, month: 10, day: 10), type: .food, amount: 6.10),
//        Expense(name: "Bus ride", date: DateComponents(year: 2025, month: 10, day: 10), type: .transport, amount: 1.70)
//    ]
    
    var allExpenses: [Expense] = []
    // UIVIews
    let expenseTableView = UITableView()
    
    private let store = ExpenseDataStore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "No money 💰"
        navigationItem.largeTitleDisplayMode = .always
        
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
        object: nil, queue: .main) { [weak self] _ in
                guard let self else { return }
                try? self.store.saveExpenses(self.allExpenses)
        }
        
        allExpenses = store.loadExpenses()
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupNavigationBar(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .brown
        
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 30)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30, weight: .semibold)]
        
        // add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewExpense))
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupTableView() {
        expenseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(expenseTableView)
        
        NSLayoutConstraint.activate([
            expenseTableView.topAnchor.constraint(equalTo: view.topAnchor),
            expenseTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expenseTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expenseTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        
        expenseTableView.dataSource = self
        expenseTableView.delegate = self
        expenseTableView.rowHeight = UITableView.automaticDimension
        expenseTableView.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
    }
    
    // MARK: Helper
    
    @objc private func addNewExpense(){
        // TODO: add new expense
        let addVC = ExpenseFormController()
        addVC.delegate = self
        let navController = UINavigationController(rootViewController: addVC)
        present(navController, animated: true)
    }
}

extension ListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = allExpenses.count
        if count == 0 {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No expenses yet!"
            noDataLabel.textColor = UIColor.gray
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expenseTableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as? ExpenseTableViewCell else {
             return UITableViewCell()
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.configure(with: allExpenses[indexPath.row])
        return cell
    }
}

extension ListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedRow = allExpenses[indexPath.row]
        
        let detailVC = ExpenseDetailViewController(expense: tappedRow, index: indexPath.row)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // TODO: check if expense has image, and adjust height accordingly
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            allExpenses.remove(at: indexPath.row)
            store.saveExpenses(allExpenses)
            expenseTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension ListViewController: ExpenseFormControllerDelegate{
    func didAddExpense(_ expense: Expense) {
        allExpenses.append(expense)
        store.saveExpenses(allExpenses)
        expenseTableView.reloadData()
    }
}

extension ListViewController: ExpenseDetailViewControllerDelegate{
    func didFinishEditing(expense updatedExpense: Expense, at index: Int) {
        if let index = allExpenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            allExpenses[index] = updatedExpense  // replace old struct with new one
            
            store.saveExpenses(allExpenses)
            expenseTableView.reloadData()
        }
    }
}
