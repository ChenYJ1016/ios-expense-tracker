//
//  ExpenseFormViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

protocol ExpenseFormControllerDelegate: AnyObject {
    func didAddExpense(_ expense: Expense)
    func didUpdateExpense(_ expense: Expense)
}

class ExpenseFormController: UITableViewController {
    // MARK: - Properties
    weak var delegate: ExpenseFormControllerDelegate?
    var expense: Expense?
    
    let textFieldCellIdentifier = "TextFieldCell"
    let datePickerCellIdentifier = "DatePickerCell"
    let typeCellIdentifier = "TypeCell"
    let pickerViewCellIdentifier = "PickerViewCell"

    
    // Data State Properties
    private var expenseName: String = ""
    private var expenseAmount: Decimal = 0.0
    private var expenseDate: Date = Date()
    private var expenseType: ExpenseType = .miscellaneous
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureForEditing()

        tableView.register(TextFieldCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: datePickerCellIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: typeCellIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: pickerViewCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupTapGesture()
        setupNavigationBar()
    }
    
    private func setupNavigationBar(){
        if expense == nil {
            title = "Add an expense"
        }else{
            title = "Edit your expense"
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }
    
    @objc private func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveTapped(){
        if let expenseToUpdate = expense{
            expenseToUpdate.name = expenseName
            expenseToUpdate.date = Calendar.current.dateComponents([.year, .month, .day], from: expenseDate)
            expenseToUpdate.type = expenseType
            expenseToUpdate.amount = expenseAmount
            
            delegate?.didUpdateExpense(expenseToUpdate)
        }else{
            let newExpense = Expense(
                name: expenseName, date: Calendar.current.dateComponents([.year, .month, .day], from: expenseDate), type: expenseType, amount: expenseAmount
            )
            
            delegate?.didAddExpense(newExpense)
        }
        
        dismiss(animated: true , completion: nil)
    }
    
    private func configureForEditing(){
        guard let expenseToEdit = expense else { return }
        
        self.expenseName = expenseToEdit.name
        self.expenseDate = Calendar.current.date(from: expenseToEdit.date) ?? Date()
        self.expenseType = expenseToEdit.type
        self.expenseAmount = expenseToEdit.amount
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 216
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            return 180
        }
        
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 3 sections for expense information, date, and amount
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
            case 0: return 3 // name, type, picker for type
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
                cell.accessoryType = .disclosureIndicator
                return cell
            case (0, 2):
                let cell = tableView.dequeueReusableCell(withIdentifier: pickerViewCellIdentifier, for: indexPath) as! PickerViewCell
                cell.pickerView.dataSource = self
                cell.pickerView.delegate = self
                
                if let selectedRow = ExpenseType.allCases.firstIndex(of: expenseType) {
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
                cell.textField.text = CurrencyFormatter.shared.string(from: expenseAmount)
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

extension ExpenseFormControllerDelegate{
    func didAddExpense(_ expense: Expense) {}
    func didUpdateExpense(_ expense: Expense) {}
}

extension ExpenseFormController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ExpenseType.allCases.count
    }
    
    
}

extension ExpenseFormController: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let expenseCase = ExpenseType.allCases[row]
        
        return expenseCase.rawValue.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.expenseType = ExpenseType.allCases[row]
        
        let typeCellIndexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [typeCellIndexPath], with: .none)
        
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
