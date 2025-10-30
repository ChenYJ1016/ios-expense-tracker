//
//  SavingGoalFormController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25
//

import UIKit

protocol SavingGoalFormControllerDelegate: AnyObject {
    func savingGoalFormController(_ controller: SavingGoalFormController, didSaveNew goal: SavingGoal)
    func savingGoalFormController(_ controller: SavingGoalFormController, didUpdate goal: SavingGoal)
    func savingGoalFormControllerDidCancel(_ controller: SavingGoalFormController)
}

class SavingGoalFormController: UITableViewController {
    
    // MARK: - Properties
    weak var delegate: SavingGoalFormControllerDelegate?
    
    var goalToEdit: SavingGoal?

    let textFieldCellIdentifier = "TextFieldCell"
    let pickerViewCellIdentifier = "PickerViewCell"
    
    private var goalName: String = ""
    private var targetAmount: Decimal = 0.0
    private var selectedIconName: String = ""
    
    private let iconData = [
        ("Default", "star.fill"),
        ("Car", "car.fill"),
        ("Travel", "airplane"),
        ("Home", "house.fill"),
        ("Gift", "gift.fill"),
        ("Education", "graduationcap.fill"),
        ("Emergency", "shield.fill")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: pickerViewCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupNavigationBar()
        
        if let goal = goalToEdit {
            title = "Edit Goal"
            goalName = goal.name
            targetAmount = goal.targetAmount
            selectedIconName = goal.iconName
        } else {
            title = "New Goal"
            selectedIconName = iconData.first?.1 ?? "star.fill"
        }
        
        setupTapGesture()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
    }

    @objc private func handleCancel() {
        delegate?.savingGoalFormControllerDidCancel(self)
    }

    @objc private func handleSave() {
        view.endEditing(true)
                
        let finalGoalName = goalName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if finalGoalName.isEmpty {
            showAlert(title: "Missing Name", message: "Please enter a name for your goal (e.g., 'Vacation Fund').")
            return
        }
        
        if targetAmount <= 0 {
            showAlert(title: "Invalid Amount", message: "Your target amount must be greater than $0.")
            return
        }
        
        if var existingGoal = goalToEdit {
            existingGoal.name = finalGoalName
            existingGoal.targetAmount = targetAmount
            existingGoal.iconName = selectedIconName
            
            delegate?.savingGoalFormController(self, didUpdate: existingGoal)
            
        } else {
            let newGoal = SavingGoal(
                name: finalGoalName,
                iconName: selectedIconName,
                savedAmount: 0,
                targetAmount: targetAmount
            )
            
            delegate?.savingGoalFormController(self, didSaveNew: newGoal)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }

    @objc private func viewTapped() {
        tableView.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Goal Details" : "Icon"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellIdentifier, for: indexPath) as! TextFieldCell
            
            if indexPath.row == 0 {
                cell.textField.placeholder = "Goal Name (e.g., 'New Car')"
                cell.textField.text = goalName
                cell.textField.keyboardType = .default
                cell.textField.delegate = self
                cell.onTextChanged = { [weak self] newText in
                    self?.goalName = newText ?? ""
                }
            } else {
                cell.textField.placeholder = "How much to save?"
                cell.textField.keyboardType = .decimalPad
                cell.textField.delegate = self
                
                if !cell.textField.isEditing {
                    cell.textField.text = CurrencyFormatter.shared.string(from: targetAmount)
                } else {
                    cell.textField.text = targetAmount == 0 ? "" : "\(targetAmount)"
                }
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: pickerViewCellIdentifier, for: indexPath) as! PickerViewCell
            cell.pickerView.dataSource = self
            cell.pickerView.delegate = self
            
            if let selectedRow = iconData.firstIndex(where: { $0.1 == selectedIconName }) {
                cell.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 1 ? 180 : UITableView.automaticDimension
    }
}

// MARK: - PickerView Delegate & DataSource
extension SavingGoalFormController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return iconData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return iconData[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIconName = iconData[row].1
    }
}

// MARK: - TextField Delegate
extension SavingGoalFormController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewTapped()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType == .decimalPad {
            guard let result = CurrencyFormatter.shared.formattedReplacement(currentText: textField.text ?? "", range: range, replacement: string) else {
                return false
            }
            textField.text = result.formatted
            self.targetAmount = result.decimal ?? 0
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.keyboardType == .decimalPad {
            if targetAmount == 0 {
                textField.text = ""
            } else {
                textField.text = "\(targetAmount)"
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.keyboardType == .decimalPad {
            textField.text = CurrencyFormatter.shared.string(from: self.targetAmount)
        }
    }
}
