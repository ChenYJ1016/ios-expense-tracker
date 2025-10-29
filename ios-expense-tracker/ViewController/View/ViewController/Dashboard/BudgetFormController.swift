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
    
    private var incomeTextField: UITextField!
    private var savingGoalTextField: UITextField!
    private var remainingAmountLabel: UILabel!
    
    weak var delegate: BudgetFormControllerDelegate?
    
    // Table View for Saving Goals
    private let goalsTableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.layer.cornerRadius = 8
        // TODO: Register your custom UITableViewCell here
        // tv.register(SavingGoalCell.self, forCellReuseIdentifier: "SavingGoalCell")
        return tv
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    
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
    
    private let formSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Income & Savings", "Saving Goals"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let overviewContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let goalsContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Budget", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Monthly Budget"
        
        setupUI()
        setupNavigationItems()
        setupOverviewContainer()
        setupGoalsContainer()
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
        contentStackView.addArrangedSubview(formSegmentedControl)
        contentStackView.addArrangedSubview(overviewContainerView)
        contentStackView.addArrangedSubview(goalsContainerView)
        contentStackView.addArrangedSubview(saveButton)
        
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
            
            // Save button height
            saveButton.heightAnchor.constraint(equalToConstant: 50)

            
            
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
        incomeTextField = createTextField(placeholder: "e.g., 3000", keyboardType: .decimalPad)
        
        let goalTitle = createTitleLabel(with: "Overall Saving Goal")
        savingGoalTextField = createTextField(placeholder: "e.g., 500", keyboardType: .decimalPad)
        
        let remainingTitle = createTitleLabel(with: "Remaining for Spending")
        remainingAmountLabel = createAmountLabel(with: "$0.00") // Default value
        
        // Add components to the stack view
        stackView.addArrangedSubview(incomeTitle)
        stackView.addArrangedSubview(incomeTextField)
        stackView.setCustomSpacing(24, after: incomeTextField) // Add extra space
        
        stackView.addArrangedSubview(goalTitle)
        stackView.addArrangedSubview(savingGoalTextField)
        stackView.setCustomSpacing(24, after: savingGoalTextField) // Add extra space
        
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
    
    private func setupGoalsContainer() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        
        goalsContainerView.addSubview(stackView)
        
        // 1. Info Label
        let infoLabel = createTitleLabel(with: "Breakdown Your Saving Goal")
        infoLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        // 2. Error Label (hidden by default)
        let errorLabel = UILabel()
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.text = "Your goals don't add up to your total."
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true // Show this with logic later
        
        // 3. Add Goal Button
        let addGoalButton = UIButton(type: .system)
        addGoalButton.translatesAutoresizingMaskIntoConstraints = false
        addGoalButton.setTitle("+ Add New Goal", for: .normal)
        addGoalButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        addGoalButton.backgroundColor = .systemGray5
        addGoalButton.layer.cornerRadius = 8
        
        // Set up TableView
        goalsTableView.delegate = self
        goalsTableView.dataSource = self
        
        // Add components to the stack view
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(goalsTableView)
        stackView.addArrangedSubview(addGoalButton)
        
        // Pin the stackView to its container
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: goalsContainerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: goalsContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: goalsContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: goalsContainerView.trailingAnchor),
            
            addGoalButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Initialize the height constraint for the table view.
        // We start it at 0. We will update this in `viewDidLayoutSubviews`.
        tableViewHeightConstraint = goalsTableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint.isActive = true
    }
    
    // This method is called after the table view has its content.
    // We update the height constraint to match the table's content size.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update height constraint
        let newHeight = goalsTableView.contentSize.height
        if tableViewHeightConstraint.constant != newHeight {
            tableViewHeightConstraint.constant = newHeight
        }
    }

    // MARK: - Actions
    
    private func setupActions() {
        // Add target for the segmented control
        formSegmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // TODO: Add target for saveButton
         saveButton.addTarget(self, action: #selector(savedTapped), for: .touchUpInside)
        
        // TODO: Add targets for text fields to update the 'Remaining' label
        // incomeTextField.addTarget(self, action: #selector(updateRemainingBalance), for: .editingChanged)
        // savingGoalTextField.addTarget(self, action: #selector(updateRemainingBalance), for: .editingChanged)
    }
    
    @objc private func segmentChanged() {
        let isOverviewSelected = formSegmentedControl.selectedSegmentIndex == 0
        
        UIView.animate(withDuration: 0.3) {
            self.overviewContainerView.isHidden = !isOverviewSelected
            self.goalsContainerView.isHidden = isOverviewSelected
            
            // This tells the stack view to re-layout
            self.contentStackView.layoutIfNeeded()
        }
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

// MARK: - UITableView Delegate & DataSource

extension BudgetFormController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Return your array of saving goals count
        return 3 // Placeholder
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Dequeue your custom cell
        // let cell = tableView.dequeueReusableCell(withIdentifier: "SavingGoalCell", for: indexPath) as! SavingGoalCell
        
        // Placeholder cell
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = "Goal \(indexPath.row + 1)"
        cell.detailTextLabel?.text = "$100.00"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Present your 'Add/Edit Goal' modal view controller
        print("Tapped on goal \(indexPath.row)")
    }
    
    // TODO: Add swipe-to-delete functionality
}

#Preview {
    BudgetFormController()
    
}
