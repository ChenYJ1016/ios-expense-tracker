//
//  BudgetFormController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import UIKit

protocol BudgetFormControllerDelegate: AnyObject {
    func budgetFormController(didSave budget: Budget)
}

class BudgetFormController: UIViewController {

    // MARK: - Properties
    
    var onTextChanged: ((String?) -> Void)?
    private var incomeTextField: UITextField!
    private var savingGoalTextField: UITextField!
    private var remainingAmountLabel: UILabel!
    
    weak var delegate: BudgetFormControllerDelegate?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return sv
    }()
    
    private let overviewContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Monthly Budget"
        
        setupUI()
        setupNavigationItems()
        setupOverviewContainer()
        setupActions()
        setupKeyboardDismissGesture()
    }
    
    // MARK: - UI Setup
    
    private func setupNavigationItems() {
        let saveIcon = UIImage(systemName: "checkmark")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: saveIcon, style: .prominent, target: self, action: #selector(savedTapped))
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(overviewContainerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }
    
    private func setupOverviewContainer() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        overviewContainerView.addSubview(stackView)
        
        let incomeTitle = createTitleLabel(with: "Your Monthly Income")
        incomeTextField = createTextField(placeholder: "$0.00", keyboardType: .decimalPad)
        incomeTextField.delegate = self
        
        let goalTitle = createTitleLabel(with: "Saving goal this month")
        savingGoalTextField = createTextField(placeholder: "$0.00", keyboardType: .decimalPad)
        savingGoalTextField.delegate = self
        
        let remainingTitle = createTitleLabel(with: "Your budget for this month")
        remainingAmountLabel = createAmountLabel(with: "$0.00")
        
        stackView.addArrangedSubview(incomeTitle)
        stackView.addArrangedSubview(incomeTextField)
        stackView.setCustomSpacing(24, after: incomeTextField)
        
        stackView.addArrangedSubview(goalTitle)
        stackView.addArrangedSubview(savingGoalTextField)
        stackView.setCustomSpacing(24, after: savingGoalTextField)
        
        stackView.addArrangedSubview(remainingTitle)
        stackView.addArrangedSubview(remainingAmountLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: overviewContainerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: overviewContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: overviewContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: overviewContainerView.trailingAnchor)
        ])
    }


    // MARK: - Actions
    
    private func setupActions() {
        incomeTextField.addTarget(self, action: #selector(updateRemainingBalance), for: .editingChanged)
        savingGoalTextField.addTarget(self, action: #selector(updateRemainingBalance), for: .editingChanged)
    }
    
    @objc private func updateRemainingBalance() {
        let income = Decimal(string: incomeTextField.text ?? "") ?? 0
        let goal = Decimal(string: savingGoalTextField.text ?? "") ?? 0
        
        let remainingBalance = income - goal
        
        if remainingBalance < 0 {
            remainingAmountLabel.textColor = .systemRed
        } else {
            remainingAmountLabel.textColor = .systemGreen
        }
        
        remainingAmountLabel.text = CurrencyFormatter.shared.string(from: remainingBalance)
    }
    
    @objc private func savedTapped() {
        // 1. Validate Income
        guard let incomeText = incomeTextField.text,
              !incomeText.isEmpty,
              let income = Decimal(string: incomeText) else {
            
            showAlert(title: "Invalid Income", message: "Please enter a valid monthly income.")
            return
        }
        
        if income <= 0 {
            showAlert(title: "Invalid Income", message: "Your monthly income must be greater than $0.")
            return
        }
        
        let goalText = savingGoalTextField.text ?? ""
        let goal = Decimal(string: goalText) ?? 0
        
        if goal < 0 {
            showAlert(title: "Invalid Goal", message: "Your saving goal cannot be a negative amount.")
            return
        }
        
        if goal > income {
            showAlert(title: "Invalid Goal", message: "Your saving goal cannot be greater than your income.")
            return
        }
        
        let newBudget = Budget(income: income, savingGoal: goal)
        delegate?.budgetFormController(didSave: newBudget)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helper UI Creation Methods
    
    private func createTitleLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }
    
    private func createTextField(placeholder: String, keyboardType: UIKeyboardType) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 8
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return textField
    }
    
    private func createAmountLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .systemGreen
        return label
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension BudgetFormController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let result = CurrencyFormatter.shared.formattedReplacement(currentText: textField.text ?? "", range: range, replacement: string) else {
            return false
        }
        
        textField.text = result.formatted

        textField.sendActions(for: .editingChanged)
        
        return false
    }
}
