import UIKit

protocol ExpenseDetailViewControllerDelegate : AnyObject{
    func didFinishEditing(expense: Expense)
}

class ExpenseDetailViewController: UITableViewController {
    
    weak var delegate: ExpenseDetailViewControllerDelegate?
    var expense: Expense

    
    private let detailCellIdentifier = "ExpenseDetailCell"
    
    init(expense: Expense) {
        self.expense = expense
        super.init(style: .insetGrouped)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = expense.name

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: detailCellIdentifier)
        self.setupNavigationBar()
        
        self.setupHeaderView()
    }
    
    // MARK: - UI Setup
    
    private func setupNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editCurrentExpense))
    }
    
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        
        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.text = CurrencyFormatter.shared.string(from: expense.amount)
        amountLabel.font = .systemFont(ofSize: 44, weight: .bold)
        amountLabel.textColor = .label
        amountLabel.textAlignment = .center
        
        headerView.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10)
        ])
        
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Details"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            content.text = "Date"
            content.secondaryText = expense.date.formatted(date: .long, time: .omitted)
        case 1:
            content.text = "Expense Type"
            content.secondaryText = expense.type.rawValue.capitalized
        default:
            break
        }
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
    
    @objc private func editCurrentExpense(){
        let editVC = ExpenseFormController()
        editVC.delegate = self
        editVC.expense = self.expense
        let navController = UINavigationController(rootViewController: editVC)
        present(navController, animated: true)
    }
}

// MARK: - Delegate Conformance
extension ExpenseDetailViewController: ExpenseFormControllerDelegate {
    func didUpdateExpense(_ expense: Expense) {
        self.expense = expense
        
        self.title = expense.name
        self.setupHeaderView()
        self.tableView.reloadData()
        
        delegate?.didFinishEditing(expense: expense)
    }
}
