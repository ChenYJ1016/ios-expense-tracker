//
//  SavingGoalFormController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import UIKit

/// A protocol to communicate when a goal is saved.
protocol SavingGoalFormControllerDelegate: AnyObject {
    func savingGoalFormController(_ controller: SavingGoalFormController, didSaveNew goal: SavingGoal)
    
    // TODO: You can add this later to support editing
    // func savingGoalFormController(_ controller: SavingGoalFormController, didUpdate goal: SavingGoal)
}

class SavingGoalFormController: UIViewController {
    
    weak var delegate: SavingGoalFormControllerDelegate?
    
    // TODO: Add an 'init' and 'goalToEdit' property later to support editing
    
    // --- UI Components ---
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Goal Name"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "e.g., New Car"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .words
        tf.returnKeyType = .next
        return tf
    }()
    
    private let targetAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "Target Amount"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let targetAmountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "e.g., 20000"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.returnKeyType = .done
        return tf
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.text = "Icon"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let iconPicker: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    /// A simple list of SFSymbol icon names to choose from.
    private let iconData: [String] = [
        "car.fill", "airplane", "house.fill", "graduationcap.fill", "bag.fill",
        "cart.fill", "shield.fill", "gift.fill", "banknote.fill", "gamecontroller.fill"
    ]
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            nameLabel, nameTextField,
            targetAmountLabel, targetAmountTextField,
            iconLabel, iconPicker
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(20, after: nameTextField)
        stack.setCustomSpacing(20, after: targetAmountTextField)
        return stack
    }()
    
    
    // --- View Lifecycle ---
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Saving Goal"
        view.backgroundColor = .systemGroupedBackground
        
        setupNavBar()
        setupUI()
        
        iconPicker.delegate = self
        iconPicker.dataSource = self
        
        // Select a default icon
        iconPicker.selectRow(0, inComponent: 0, animated: false)
    }
    
    // --- Setup ---
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSaveTapped))
    }
    
    private func setupUI() {
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // --- Actions ---
    
    @objc private func handleCancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleSaveTapped() {
        // 1. Validate Input
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Missing Name", message: "Please enter a name for your goal.")
            return
        }
        
        guard let amountText = targetAmountTextField.text,
              let targetAmount = Decimal(string: amountText),
              targetAmount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a target amount greater than zero.")
            return
        }
        
        // 2. Get Selected Icon
        let selectedIcon = iconData[iconPicker.selectedRow(inComponent: 0)]
        
        // 3. Create New Goal
        let newGoal = SavingGoal(
            name: name,
            iconName: selectedIcon,
            savedAmount: 0,
            targetAmount: targetAmount 
        )
        
        // 4. Send to Delegate
        delegate?.savingGoalFormController(self, didSaveNew: newGoal)
        
        // 5. Dismiss
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// ---
// MARK: - UIPickerView Delegate & DataSource
// ---
extension SavingGoalFormController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return iconData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return iconData[row]
    }
}
