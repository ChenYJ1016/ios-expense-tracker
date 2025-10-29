//
//  ExpenseFormViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

protocol ExpenseFormControllerDelegate: AnyObject {
    // (MODIFIED) Simplified the delegate, as the stores will post notifications
    func expenseFormControllerDidFinish(controller: ExpenseFormController)
}

class ExpenseFormController: UITableViewController {
    
    // MARK: - Properties
    weak var delegate: ExpenseFormControllerDelegate?
    var expense: Expense?
    
    // (NEW) Add the data stores
    private let expenseStore = ExpenseDataStore.shared
    private let savingGoalStore = SavingGoalDataStore.shared
        
    let textFieldCellIdentifier = "TextFieldCell"
    let datePickerCellIdentifier = "DatePickerCell"
    let typeCellIdentifier = "TypeCell"
    let pickerViewCellIdentifier = "PickerViewCell"
    // (NEW) Add a new identifier for the goal picker cell
    let goalPickerCellIdentifier = "GoalPickerCell"

    
    // Data State Properties
    private var expenseName: String = ""
    private var expenseAmount: Decimal = 0.0
    private var expenseDate: Date = Date()
    private var expenseType: ExpenseType = .misc
    
    // (NEW) Add state for the saving goals
    private var availableGoals: [SavingGoal] = []
    private var selectedGoal: SavingGoal?
    
    // (NEW) Constants for picker tags
    private let typePickerTag = 1
    private let goalPickerTag = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // (NEW) Load available goals
        loadSavingGoals()
        
        configureForEditing()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: datePickerCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: typeCellIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: pickerViewCellIdentifier)
        // (NEW) Register the new cell identifier
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: goalPickerCellIdentifier)

        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTapGesture()
        setupNavigationBar()
    }
    
    // (NEW) Helper to load goals and set a default
    private func loadSavingGoals() {
        self.availableGoals = savingGoalStore.loadSavingGoals()
        
        // If we are *not* editing, or if the expense being edited isn't
        // a saving goal, set default to the first available goal.
        if expense == nil || expense?.type != .savings {
             self.selectedGoal = availableGoals.first
        }
        
        // (TODO: When editing, you'll need to link the expense to its goal,
        // probably by adding a 'goalID: UUID?' to your Expense model,
        // and then find and set 'self.selectedGoal' here.)
    }
    
    private func setupNavigationBar(){
        if expense == nil {
            title = "Add an expense"
        }else{
            title = "Edit your expense"
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        // (MODIFIED) Changed icon to "checkmark" for saving
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped))
    }
    
    @objc private func handleCancel(){
        delegate?.expenseFormControllerDidFinish(controller: self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped(){
        // Resign first responder to make sure all data is saved from text fields
        view.endEditing(true)
        
        if var expenseToUpdate = expense {
            // This is an *existing* expense being updated
            expenseToUpdate.name = expenseName
            expenseToUpdate.date = expenseDate
            expenseToUpdate.type = expenseType
            expenseToUpdate.amount = expenseAmount
            
            // (MODIFIED) Tell the store to save, which posts a notification
            expenseStore.updateExpense(expenseToUpdate)
            
            // (NEW) Handle logic for updating saving goals (This is complex)
            // For example, if the user changed the amount, or changed the category
            // from "Food" to "Savings", we would need to add/subtract from goals.
            // For now, we'll only handle this for *new* expenses.
            print("--- TODO: Handle saving goal updates when *editing* an expense ---")

            
        } else {
            // This is a *new* expense
            let newExpense = Expense(
                name: expenseName, date: expenseDate, type: expenseType, amount: expenseAmount
            )
            
            // (MODIFIED) Tell the store to save, which posts a notification
            expenseStore.addExpense(newExpense)
            
            // (NEW) If this is a savings expense, update the goal's progress!
            if newExpense.type == .savings {
                if availableGoals.isEmpty {
                    print("User saved a 'Savings' expense but has no goals set up.")
                }
                // Make sure a goal was actually selected
                else if let goalToUpdate = self.selectedGoal {
                    // This is the magic!
                    savingGoalStore.add(amount: newExpense.amount, to: goalToUpdate)
                } else {
                    // This case shouldn't happen if !availableGoals.isEmpty
                    print("Error: Savings expense saved but no goal was selected.")
                }
            }
        }
        
        delegate?.expenseFormControllerDidFinish(controller: self)
        dismiss(animated: true , completion: nil)
    }
    
    private func configureForEditing(){
        guard let expenseToEdit = expense else { return }
        
        self.expenseName = expenseToEdit.name
        self.expenseDate = expenseToEdit.date
        self.expenseType = expenseToEdit.type
        self.expenseAmount = expenseToEdit.amount
        
        // (NEW) TODO: When editing, we'd also need to load
        // which goal this expense was for.
        // self.selectedGoal = savingGoalStore.getGoal(id: expenseToEdit.goalID)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // (MODIFIED) Check for all picker heights
        if indexPath.section == 0 {
            // Row 2: Type Picker
            if indexPath.row == 2 {
                return 180
            }
            // (NEW) Row 3 & 4: Goal Label and Picker
            if indexPath.row == 3 || indexPath.row == 4 {
                // Check if we should show these rows
                if expenseType == .savings && !availableGoals.isEmpty {
                    // Row 4 (Goal Picker)
                    if indexPath.row == 4 {
                        return 180
                    }
                    // Row 3 (Goal Label)
                    return UITableView.automaticDimension
                } else {
                    // Hide these rows
                    return 0
                }
            }
        }

        if indexPath.section == 1 && indexPath.row == 0 {
            return 216
        }
        
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "Expense Information"
            case 1: return "Date"
            case 2: return "Expense Amount"
            default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            // (MODIFIED) Section 0 now always has 5 rows (some may be hidden)
            case 0: return 5 // name, type, type picker, goal, goal picker
            case 1: return 1 // date picker
            case 2: return 1 // amount
            default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath.section, indexPath.row){
            case (0,0):
                let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellIdentifier, for: indexPath) as! TextFieldCell
                cell.textField.placeholder = "Expense Name"
                cell.textField.text = expenseName
                cell.textField.delegate = self
                
                cell.onTextChanged = { [weak self] newText in
                    self?.expenseName = newText ?? ""
                }
                return cell
            case (0, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: typeCellIdentifier, for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "Type"
                content.secondaryText = expenseType.rawValue.capitalized
                cell.contentConfiguration = content
                cell.accessoryType = .none // This cell doesn't navigate
                return cell
            case (0, 2):
                let cell = tableView.dequeueReusableCell(withIdentifier: pickerViewCellIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                cell.pickerView.tag = typePickerTag // (NEW) Tag this as the type picker
                
                if let selectedRow = ExpenseType.allCases.firstIndex(of: expenseType) {
                    cell.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                        
                return cell
            
            // --- (NEW) ROWS 3 & 4 FOR SAVING GOAL ---
            
            case (0, 3):
                let cell = tableView.dequeueReusableCell(withIdentifier: typeCellIdentifier, for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "Goal"
                // Show the selected goal, or a message if none exist
                if availableGoals.isEmpty {
                    content.secondaryText = "No goals created"
                } else {
                    content.secondaryText = selectedGoal?.name ?? "None"
                }
                cell.contentConfiguration = content
                
                // (NEW) Hide if not a savings expense or no goals
                let isHidden = (expenseType != .savings || availableGoals.isEmpty)
                cell.isHidden = isHidden
                cell.contentView.isHidden = isHidden
                
                return cell

            case (0, 4):
                let cell = tableView.dequeueReusableCell(withIdentifier: goalPickerCellIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                cell.pickerView.tag = goalPickerTag // (NEW) Tag this as the goal picker
                
                if let goal = selectedGoal, let selectedRow = availableGoals.firstIndex(of: goal) {
                    cell.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                
                // (NEW) Hide if not a savings expense or no goals
                let isHidden = (expenseType != .savings || availableGoals.isEmpty)
                cell.isHidden = isHidden
                cell.contentView.isHidden = isHidden
                
                return cell

            // --- END OF NEW ROWS ---

            case (1, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: datePickerCellIdentifier, for: indexPath) as! DatePickerCell
                cell.datePicker.date = expenseDate
                cell.onDateChanged = { [weak self]  newDate in
                    self?.expenseDate = newDate
                }
            return cell
            case (2, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellIdentifier, for: indexPath) as! TextFieldCell
                
                cell.textField.placeholder = "Total expense"
                // (MODIFIED) Only format if not editing
                if !cell.textField.isEditing {
                    cell.textField.text = CurrencyFormatter.shared.string(from: expenseAmount)
                }
                
                cell.textField.keyboardType = .decimalPad
                cell.textField.delegate = self
                
                return cell
            default:
                return UITableViewCell()
        }
    }

    private func setupTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func viewTapped(){
        // resigns first responder, in this case dismisses keyboard
        tableView.endEditing(true)
    }

}

// (MODIFIED) Simplified delegate
extension ExpenseFormControllerDelegate{
    func expenseFormControllerDidFinish(controller: ExpenseFormController) {}
}

extension ExpenseFormController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int { // (FIXED) Typo
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // (MODIFIED) Check which picker we're providing data for
        if pickerView.tag == typePickerTag {
            return ExpenseType.allCases.count
        } else {
            return availableGoals.count
        }
    }
    
    
}

extension ExpenseFormController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // (MODIFIED) Check which picker we're providing data for
        if pickerView.tag == typePickerTag {
            let expenseCase = ExpenseType.allCases[row]
            return expenseCase.rawValue.capitalized
        } else {
            // (MODIFIED) Handle case where no goals exist yet
            guard !availableGoals.isEmpty else { return "No Goals" }
            return availableGoals[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // (MODIFIED) Check which picker was selected
        if pickerView.tag == typePickerTag {
            self.expenseType = ExpenseType.allCases[row]
            
            // Reload the "Type" label cell
            let typeCellIndexPath = IndexPath(row: 1, section: 0)
            
            // (NEW) Reload the goal cells to show/hide them
            let goalLabelIndexPath = IndexPath(row: 3, section: 0)
            let goalPickerIndexPath = IndexPath(row: 4, section: 0)

            // (NEW) Update table view to show/hide goal cells
            // We just reload the section to handle height changes
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            // If we just selected "Savings", make sure we have a goal selected
            if self.expenseType == .savings {
                self.selectedGoal = availableGoals.first
                tableView.reloadRows(at: [goalLabelIndexPath], with: .none)
            }
            
        } else {
            // (NEW) The goal picker was selected
            if !availableGoals.isEmpty {
                self.selectedGoal = availableGoals[row]
                
                // Reload the "Goal" label cell
                let goalCellIndexPath = IndexPath(row: 3, section: 0)
                tableView.reloadRows(at: [goalCellIndexPath], with: .none)
            }
        }
    }
}

extension ExpenseFormController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewTapped()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.keyboardType == .decimalPad{
            // This is your existing currency formatting logic.
            // This is great for making it look good *while typing*.
            guard let result = CurrencyFormatter.shared.formattedReplacement(currentText: textField.text ?? "", range: range, replacement: string) else{
                return false
            }
            
            textField.text = result.formatted
            // We still update the amount here
            self.expenseAmount = result.decimal ?? 0
            return false
        }
        
        return true
    }
    
    // (REMOVED) textFieldDidBeginEditing is not needed,
    // your `shouldChangeCharactersIn` handles formatted text.
    
    // (REMOVED) textFieldDidEndEditing is not needed,
    // `self.expenseAmount` is already set in `shouldChangeCharactersIn`.
}

