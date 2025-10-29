//
//  BudgetFormController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 29/10/25.
//

import UIKit

protocol BudgetFormControllerDelegate: AnyObject{
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
    
    private func setupNavigationItems(){
        
        
        let saveIcon = UIImage(systemName: "checkmark")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: saveIcon, style: .prominent, target: self, action: #selector(savedTapped))
    }
    
    private func setupUI(){
        // 1. Add ScrollView to the main view
        view.addSubview(scrollView)
        
        // 2. Add ContentStackView to the ScrollView
        scrollView.addSubview(contentStackView)
        
        // 3. Add components to the ContentStackView
        contentStackView.addArrangedSubview(overviewContainerView)
        
        // 4. Set constraints
        NSLayoutConstraint.activate([
            // ScrollView constraints (pins to safe area)
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // ContentStackView constraints
            // Pins to scroll view's content area
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            // This is key: ContentStackView's width must equal the scroll view's frame width
            // This prevents horizontal scrolling.
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
        ])
    }
    
    private func setupOverviewContainer() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        overviewContainerView.addSubview(stackView)
        
        // Create and configure form fields
        let incomeTitle = createTitleLabel(with: "Your Monthly Income")
        incomeTextField = createTextField(placeholder: "$0.00", keyboardType: .decimalPad)
        incomeTextField.delegate = self
        
        let goalTitle = createTitleLabel(with: "Saving goal this month")
        savingGoalTextField = createTextField(placeholder: "$0.00", keyboardType: .decimalPad)
        
        let remainingTitle = createTitleLabel(with: "Your budget for this month")
        remainingAmountLabel = createAmountLabel(with: "$0.00")
        
        // Add components to the stack view
        stackView.addArrangedSubview(incomeTitle)
        stackView.addArrangedSubview(incomeTextField)
        stackView.setCustomSpacing(24, after: incomeTextField)
        
        stackView.addArrangedSubview(goalTitle)
        stackView.addArrangedSubview(savingGoalTextField)
        stackView.setCustomSpacing(24, after: savingGoalTextField)
        
        stackView.addArrangedSubview(remainingTitle)
        stackView.addArrangedSubview(remainingAmountLabel)
        
        // Pin the stackView to its container
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: overviewContainerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: overviewContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: overviewContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: overviewContainerView.trailingAnchor)
        ])
    }


    // MARK: - Actions
    
    private func setupActions() {
        
        // Add targets for text fields to update the 'Remaining' label
         incomeTextField.addTarget(self, action: #selector(updateRemainingBalance), for: .editingChanged)
         savingGoalTextField.addTarget(self, action: #selector(updateRemainingBalance), for: .editingChanged)
    }
    
    @objc private func updateRemainingBalance() {
        guard let incomeText = incomeTextField.text, !incomeText.isEmpty, let income = Decimal(string: incomeText), let goalText = savingGoalTextField.text, !goalText.isEmpty, let goal = Decimal(string: goalText) else {
            remainingAmountLabel.text = "N/A"
            return
        }
        
        let remainingBalance = income - goal
        remainingAmountLabel.text = CurrencyFormatter.shared.string(from: remainingBalance) 
    }
    
    @objc private func savedTapped(){
        guard let incomeText = incomeTextField.text, !incomeText.isEmpty, let income = Decimal(string: incomeText), let goalText = savingGoalTextField.text, !goalText.isEmpty, let goal = Decimal(string: goalText) else {
            // TODO: show alert
            print("Invalid input")
            return
        }
        
        let newBudget = Budget(income: income, savingGoal: goal)
        delegate?.budgetFormController(didSave: newBudget)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelTapped(){
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
        
        // Add padding
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
  
}

extension BudgetFormController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // format the textfield value
        guard let result = CurrencyFormatter.shared.formattedReplacement(currentText: textField.text ?? "", range: range, replacement: string) else{
            return false
        }
        
        textField.text = result.formatted

        return false
        
    }
}
