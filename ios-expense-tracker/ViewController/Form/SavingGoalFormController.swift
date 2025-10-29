//
//  SavingGoalFormController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25
//

import UIKit

// (MODIFIED) Updated the delegate protocol
protocol SavingGoalFormControllerDelegate: AnyObject {
    func savingGoalFormController(_ controller: SavingGoalFormController, didSaveNew goal: SavingGoal)
    func savingGoalFormController(_ controller: SavingGoalFormController, didUpdate goal: SavingGoal)
    func savingGoalFormControllerDidCancel(_ controller: SavingGoalFormController)
}

class SavingGoalFormController: UITableViewController {
    
    // MARK: - Properties
    weak var delegate: SavingGoalFormControllerDelegate?
    
    // (NEW) This property will be set when we want to edit.
    // If this is nil, we are in "Add New" mode.
    var goalToEdit: SavingGoal?

    // Cell Identifiers
    let textFieldCellIdentifier = "TextFieldCell"
    let pickerViewCellIdentifier = "PickerViewCell"
    
    // Data State Properties
    private var goalName: String = ""
    private var targetAmount: Decimal = 0.0
    private var selectedIconName: String = ""
    
    // Icon Picker Data
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
        
        // Register cells
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: textFieldCellIdentifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: pickerViewCellIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupNavigationBar()
        
        // (NEW) Check if we are in "Edit Mode" or "Add Mode"
        if let goal = goalToEdit {
            // --- EDIT MODE ---
            title = "Edit Goal"
            // Pre-fill the form
            goalName = goal.name
            targetAmount = goal.targetAmount
            selectedIconName = goal.iconName
        } else {
            // --- ADD MODE ---
            title = "New Goal"
            // Set default icon
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
        // Resign first responder to save any text field changes
        view.endEditing(true)
        
        // (MODIFIED) Check if we are editing or saving new
        if var existingGoal = goalToEdit {
            // --- EDIT MODE ---
            // Update the existing goal object
            existingGoal.name = goalName
            existingGoal.targetAmount = targetAmount
            existingGoal.iconName = selectedIconName
            
            // Call the 'didUpdate' delegate method
            delegate?.savingGoalFormController(self, didUpdate: existingGoal)
            
        } else {
            // --- ADD MODE ---
            // Create a new goal object
            let newGoal = SavingGoal(
                name: goalName,
                iconName: selectedIconName, // Use the correct order
                savedAmount: 0, // New goals always start at 0
                targetAmount: targetAmount
            )
            
            // Call the 'didSaveNew' delegate method
            delegate?.savingGoalFormController(self, didSaveNew: newGoal)
        }
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
        return 2 // Section 1: Name, Amount. Section 2: Icon
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Goal Details" : "Icon"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            // --- Section 0: Name and Amount ---
            let cell = tableView.dequeueReusableCell(withIdentifier: textFieldCellIdentifier, for: indexPath) as! TextFieldCell
            
            if indexPath.row == 0 {
                // Goal Name
                cell.textField.placeholder = "Goal Name (e.g., 'New Car')"
                cell.textField.text = goalName
                cell.textField.keyboardType = .default
                cell.textField.delegate = self
                cell.onTextChanged = { [weak self] newText in
                    self?.goalName = newText ?? ""
                }
            } else {
                // Target Amount
                cell.textField.placeholder = "How much to save?"
                cell.textField.keyboardType = .decimalPad
                cell.textField.delegate = self
                
                // Pre-fill with formatted currency
                // (MODIFIED) Always format here, textFieldDidBeginEditing will handle showing raw number
                cell.textField.text = CurrencyFormatter.shared.string(from: targetAmount)
            }
            return cell
            
        } else {
            // --- Section 1: Icon Picker ---
            let cell = tableView.dequeueReusableCell(withIdentifier: pickerViewCellIdentifier, for: indexPath) as! PickerViewCell
            cell.pickerView.dataSource = self
            cell.pickerView.delegate = self
            
            // Select the row for the current icon
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
        return iconData[row].0 // Show the name (e.g., "Car")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIconName = iconData[row].1 // Save the icon name (e.g., "car.fill")
    }
}

// MARK: - TextField Delegate
extension SavingGoalFormController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        viewTapped()
        return false
    }
    
    // Use the same robust currency handling as your Expense form
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType == .decimalPad {
            guard let result = CurrencyFormatter.shared.formattedReplacement(currentText: textField.text ?? "", range: range, replacement: string) else {
                return false
            }
            textField.text = result.formatted
            // Update the model property directly here
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
                // Show the plain number for easier editing
                textField.text = "\(targetAmount)"
            }
        }
    }

    // (FIXED) This only needs to format the text field,
    // as self.targetAmount is already updated in shouldChangeCharactersIn
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.keyboardType == .decimalPad {
            // Re-format the text field to show the currency string
            // using the already-updated self.targetAmount
            textField.text = CurrencyFormatter.shared.string(from: self.targetAmount)
        }
    }
}

