import UIKit

protocol ExpenseDetailViewControllerDelegate : AnyObject{
    func didFinishEditing(expense: Expense)
}

class ExpenseDetailViewController: UITableViewController {
    
    weak var delegate: ExpenseDetailViewControllerDelegate?
    var expense: Expense

    
    private let detailCellIdentifier = "ExpenseDetailCell"
    
    // (NEW) Make the header label a class property
    private var amountLabel: UILabel?
    
    init(expense: Expense) {
        self.expense = expense
        super.init(style: .insetGrouped)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title = expense.name // (MOVED to configureUI)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataDidChange),
            name: .didUpdateExpenses,
            object: nil
        )
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: detailCellIdentifier)
        self.setupNavigationBar()
        
        // (MODIFIED) Call the new setup/configure functions
        self.setupHeaderView() // Creates the header
        self.configureUI()     // Populates the header and table
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func dataDidChange() {

        if let updatedExpense = ExpenseDataStore.shared.loadExpenses().first(where: { $0.id == self.expense.id }) {
            // 2. Update the local property
            self.expense = updatedExpense

            // 3. Refresh your UI
            configureUI() // (This was the missing piece)
        } else {
            // The expense was deleted, so pop this view controller
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: - UI Setup
    
    private func setupNavigationBar(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editCurrentExpense))
    }
    
    // (MODIFIED) This just *creates* the header view now
    private func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 100))
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 44, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10)
        ])
        
        self.amountLabel = label // Assign to class property
        tableView.tableHeaderView = headerView
    }
    
    // (NEW) This function updates all UI elements with the current 'expense' data
    private func configureUI() {
        title = expense.name
        amountLabel?.text = CurrencyFormatter.shared.string(from: expense.amount)
        tableView.reloadData()
    }
    
    // MARK: - TableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // (MODIFIED) Show 3 rows if this is a "Savings" expense
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expense.type == .savings ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Details"
    }
    
    // (MODIFIED) Added 'case 2' to show the linked goal
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
        case 2:
            // (NEW) This row only shows for "Savings" expenses
            content.text = "Goal"
            if let goalID = expense.goalID,
               let goal = SavingGoalDataStore.shared.loadSavingGoals().first(where: { $0.id == goalID }) {
                content.secondaryText = goal.name
            } else {
                content.secondaryText = "None"
            }
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

// (MODIFIED) Updated to the new delegate protocol
extension ExpenseDetailViewController: ExpenseFormControllerDelegate {
    func expenseFormControllerDidFinish(controller: ExpenseFormController) {
        // The delegate's only job is to dismiss the form.
        // The notification will handle all the UI refreshing.
        controller.dismiss(animated: true)
        
        // (OLD logic, no longer needed)
        // self.expense = expense
        // self.title = expense.name
        // self.setupHeaderView()
        // self.tableView.reloadData()
        // delegate?.didFinishEditing(expense: expense)
    }
}
