//
//  ExpenseFormController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

protocol ExpenseFormControllerDelegate: AnyObject {
    func expenseFormController(didSave expense: Expense, controller: ExpenseFormController)
    func expenseFormControllerDidCancel(controller: ExpenseFormController)
}

class ExpenseFormController: UITableViewController {
    
    // MARK: - Properties
    weak var delegate: ExpenseFormControllerDelegate?
    var expense: Expense?
    
    private let expenseStore = ExpenseDataStore.shared
    private let savingGoalStore = SavingGoalDataStore.shared
        
    let textFieldCellIdentifier = "TextFieldCell"
    let datePickerCellIdentifier = "DatePickerCell"
    let typeCellIdentifier = "TypeCell"
    let pickerViewCellIdentifier = "PickerViewCell"
    let goalPickerCellIdentifier = "GoalPickerCell"

    private var expenseName: String = ""
    private var expenseAmount: Decimal = 0.0
    private var expenseDate: Date = Date()
    private var expenseType: ExpenseType = .misc
    
    private var availableGoals: [SavingGoal] = []
    private var selectedGoal: SavingGoal?
    
    private let typePickerTag = 1
    private let goalPickerTag = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavingGoals()
        configureForEditing()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: datePickerCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: typeCellIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: pickerViewCellIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: goalPickerCellIdentifier)

        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTapGesture()
        setupNavigationBar()
    }
    
    private func loadSavingGoals() {
        self.availableGoals = savingGoalStore.loadSavingGoals()
        
        if let expenseToEdit = expense, let goalID = expenseToEdit.goalID {
            self.selectedGoal = availableGoals.first(where: { $0.id == goalID })
        } else {
             if self.expenseType == .savings {
                self.selectedGoal = availableGoals.first
             }
        }
    }
    
    private func setupNavigationBar(){
        if expense == nil {
            title = "Add an expense"
        }else{
            title = "Edit your expense"
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped))
    }
    
    @objc private func handleCancel(){

        delegate?.expenseFormControllerDidCancel(controller: self)
    }
    
    @objc private func saveTapped(){
        view.endEditing(true)
        
        let finalExpenseName = expenseName.trimmingCharacters(in: .whitespacesAndNewlines)
        if finalExpenseName.isEmpty {
            showAlert(title: "Missing Name", message: "Please enter a name for this expense.")
            return
        }

        if expenseAmount <= 0 {
            showAlert(title: "Invalid Amount", message: "Please enter an amount greater than $0.")
            return
        }
        
        var finalGoalID: UUID? = nil
        if expenseType == .savings {
            if availableGoals.isEmpty {
                showAlert(title: "No Saving Goals", message: "You must create a saving goal first before you can assign a saving expense.")
                return
            }
            guard let goal = selectedGoal else {
                showAlert(title: "No Goal Selected", message: "Please select a saving goal for this expense.")
                return
            }
            finalGoalID = goal.id
        }
                
        if var expenseToUpdate = expense {
            let originalGoalID = expenseToUpdate.goalID
            let originalAmount = expenseToUpdate.amount
            
            expenseToUpdate.name = finalExpenseName
            expenseToUpdate.date = expenseDate
            expenseToUpdate.type = expenseType
            expenseToUpdate.amount = expenseAmount
            expenseToUpdate.goalID = finalGoalID
            
            expenseStore.updateExpense(expenseToUpdate, originalAmount: originalAmount, originalGoalID: originalGoalID)
            
            delegate?.expenseFormController(didSave: expenseToUpdate, controller: self)
            
        } else {
            let newExpense = Expense(
                name: finalExpenseName,
                date: expenseDate,
                type: expenseType,
                amount: expenseAmount,
                goalID: finalGoalID
            )
            
            expenseStore.addExpense(newExpense)
            
            delegate?.expenseFormController(didSave: newExpense, controller: self)
        }
        
    }
    
    private func configureForEditing(){
        guard let expenseToEdit = expense else { return }
        
        self.expenseName = expenseToEdit.name
        self.expenseDate = expenseToEdit.date
        self.expenseType = expenseToEdit.type
        self.expenseAmount = expenseToEdit.amount
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 2 { return 180 }
            if indexPath.row == 3 || indexPath.row == 4 {
                if expenseType == .savings && !availableGoals.isEmpty {
                    if indexPath.row == 4 { return 180 }
                    return UITableView.automaticDimension
                } else {
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
            case 0: return 5
            case 1: return 1
            case 2: return 1
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
                cell.accessoryType = .none
                return cell
            case (0, 2):
                let cell = tableView.dequeueReusableCell(withIdentifier: pickerViewCellIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                cell.pickerView.tag = typePickerTag
                
                if let selectedRow = ExpenseType.allCases.firstIndex(of: expenseType) {
                    cell.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                        
                return cell
            
            case (0, 3):
                let cell = tableView.dequeueReusableCell(withIdentifier: typeCellIdentifier, for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "Goal"
                if availableGoals.isEmpty {
                    content.secondaryText = "No goals created"
                } else {
                    content.secondaryText = selectedGoal?.name ?? "None"
                }
                cell.contentConfiguration = content
                                    
                return cell

            case (0, 4):
                let cell = tableView.dequeueReusableCell(withIdentifier: goalPickerCellIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                cell.pickerView.tag = goalPickerTag
                
                if let goal = selectedGoal, let selectedRow = availableGoals.firstIndex(of: goal) {
                    cell.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                                    
                return cell

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
                if !cell.textField.isEditing {
                    cell.textField.text = CurrencyFormatter.shared.string(from: expenseAmount)
                } else {
                    cell.textField.text = expenseAmount == 0 ? "" : "\(expenseAmount)"
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
        tableView.endEditing(true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

}

extension ExpenseFormController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == typePickerTag {
            return ExpenseType.allCases.count
        } else {
            return availableGoals.count
        }
    }
    
    
}

extension ExpenseFormController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == typePickerTag {
            let expenseCase = ExpenseType.allCases[row]
            return expenseCase.rawValue.capitalized
        } else {
            guard !availableGoals.isEmpty else { return "No Goals" }
            return availableGoals[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == typePickerTag {
            
            let oldExpenseType = self.expenseType
            let newExpenseType = ExpenseType.allCases[row]
            self.expenseType = newExpenseType
            
            let wasShowingGoals = (oldExpenseType == .savings && !availableGoals.isEmpty)
            let isShowingGoals = (newExpenseType == .savings && !availableGoals.isEmpty)
            
            if isShowingGoals && self.selectedGoal == nil {
                self.selectedGoal = availableGoals.first
            }

            if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
                var content = cell.defaultContentConfiguration()
                content.text = "Type"
                content.secondaryText = newExpenseType.rawValue.capitalized
                cell.contentConfiguration = content
            }
    
            if wasShowingGoals == isShowingGoals {
                return
            }
            
            tableView.beginUpdates()
            
            if isShowingGoals {
                if let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) {
                    var content = cell.defaultContentConfiguration()
                    content.text = "Goal"
                    content.secondaryText = self.selectedGoal?.name ?? "None"
                    cell.contentConfiguration = content
                }
            }
            
            tableView.endUpdates()

            if isShowingGoals {
                tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
            }


        } else {
            if !availableGoals.isEmpty {
                self.selectedGoal = availableGoals[row]
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
            guard let result = CurrencyFormatter.shared.formattedReplacement(currentText: textField.text ?? "", range: range, replacement: string) else{
                return false
            }
            
            textField.text = result.formatted
            self.expenseAmount = result.decimal ?? 0
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.keyboardType == .decimalPad {
            if expenseAmount == 0 {
                textField.text = ""
            } else {
                textField.text = "\(expenseAmount)"
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.keyboardType == .decimalPad {
            textField.text = CurrencyFormatter.shared.string(from: self.expenseAmount)
        }
    }
}
