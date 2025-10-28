import UIKit

// (We assume your 'Expense' model and 'CurrencyFormatter' are available)

class CategoryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var categoryName: String = "Category"
    var expenses: [Expense] = []
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
        
        return table
    }()
    
    /// A computed property to get the total amount for this category
    private var totalAmount: Decimal {
        return expenses.reduce(Decimal(0)) { $0 + $1.amount }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = categoryName
        view.backgroundColor = .systemGroupedBackground
        
        expenses.sort(by: { $0.date > $1.date })
        
        setupTableView()
        setupTableHeaderView()
        setupEmptyStateView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    /// --- 3. (IMPROVEMENT) Creates and sets a summary header for the table ---
    private func setupTableHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        
        let totalLabel = UILabel()
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.text = "Total Spent in \(categoryName)"
        totalLabel.font = .systemFont(ofSize: 15, weight: .medium)
        totalLabel.textColor = .secondaryLabel
        
        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = CurrencyFormatter.shared.string(from: totalAmount) ?? "$0.00"
        amountLabel.font = .systemFont(ofSize: 34, weight: .bold)
        amountLabel.textColor = .label
        
        // Stack them vertically
        let stackView = UIStackView(arrangedSubviews: [totalLabel, amountLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        
        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    private func setupEmptyStateView() {
        if expenses.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            emptyLabel.text = "No expenses in this category."
            emptyLabel.textColor = .secondaryLabel
            emptyLabel.textAlignment = .center
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as? ExpenseTableViewCell else {
            return UITableViewCell()
        }
        
        let expense = expenses[indexPath.row]
        
        cell.configure(with: expense)
        
        cell.expenseTypeLabel.isHidden = true
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedExpense = expenses[indexPath.row]
        
        let detailVC = ExpenseDetailViewController(expense: selectedExpense)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}


