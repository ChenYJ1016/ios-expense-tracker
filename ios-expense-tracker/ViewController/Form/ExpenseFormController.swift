//
//  ExpenseFormViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

protocol ExpenseFormControllerDelegate: AnyObject {
    func expenseFormControllerDidFinish(controller: ExpenseFormController)
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

    
    // Data State Properties
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
        
        if expense == nil || expense?.type != .savings {
             self.selectedGoal = availableGoals.first
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
        delegate?.expenseFormControllerDidFinish(controller: self)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped(){

        view.endEditing(true)
        
        if var expenseToUpdate = expense {
            expenseToUpdate.name = expenseName
            expenseToUpdate.date = expenseDate
            expenseToUpdate.type = expenseType
            expenseToUpdate.amount = expenseAmount
            
            expenseStore.updateExpense(expenseToUpdate)
            
        } else {
            let newExpense = Expense(
                name: expenseName, date: expenseDate, type: expenseType, amount: expenseAmount
            )
            
            expenseStore.addExpense(newExpense)
            
            if newExpense.type == .savings {
                if availableGoals.isEmpty {
                    print("User saved a 'Savings' expense but has no goals set up.")
                }
                else if let goalToUpdate = self.selectedGoal {
                    savingGoalStore.add(amount: newExpense.amount, to: goalToUpdate)
                } else {
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
   
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if indexPath.row == 2 {
                return 180
            }
            if indexPath.row == 3 || indexPath.row == 4 {
                if expenseType == .savings && !availableGoals.isEmpty {
                    if indexPath.row == 4 {
                        return 180
                    }
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
                
                let isHidden = (expenseType != .savings || availableGoals.isEmpty)
                cell.isHidden = isHidden
                cell.contentView.isHidden = isHidden
                
                return cell

            case (0, 4):
                let cell = tableView.dequeueReusableCell(withIdentifier: goalPickerCellIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                cell.pickerView.tag = goalPickerTag
                
                if let goal = selectedGoal, let selectedRow = availableGoals.firstIndex(of: goal) {
                    cell.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                
                let isHidden = (expenseType != .savings || availableGoals.isEmpty)
                cell.isHidden = isHidden
                cell.contentView.isHidden = isHidden
                
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

}

extension ExpenseFormControllerDelegate{
    func expenseFormControllerDidFinish(controller: ExpenseFormController) {}
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
            self.expenseType = ExpenseType.allCases[row]
            
            let typeCellIndexPath = IndexPath(row: 1, section: 0)
            
            let goalLabelIndexPath = IndexPath(row: 3, section: 0)
            let goalPickerIndexPath = IndexPath(row: 4, section: 0)

            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            if self.expenseType == .savings {
                self.selectedGoal = availableGoals.first
                tableView.reloadRows(at: [goalLabelIndexPath], with: .none)
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
    
   
}

