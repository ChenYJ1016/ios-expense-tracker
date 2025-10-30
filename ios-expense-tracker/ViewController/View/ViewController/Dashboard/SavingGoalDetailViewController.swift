//
//  SavingGoalDetailViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 30/10/25.
//

import UIKit

class SavingGoalDetailViewController: UIViewController {

    // MARK: - Properties
    
    var goal: SavingGoal?
    var transactions: [Expense] = []

    private let savingGoalStore = SavingGoalDataStore.shared

    // MARK: - UI Components
    
    private let goalProgressCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var progressBar: RoundedProgressView = {
        let pv = RoundedProgressView(cornerRadius: 8)
        pv.trackTintColor = .systemGray5
        return pv
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = .clear
        return tv
    }()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title =  "Saving Goal"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        setupNavBarButtons()
        refreshGoalProgressData()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        setupGoalProgressCard()
        setupTableView()
    }
    
    private func setupGoalProgressCard() {
        view.addSubview(goalProgressCardView)
        
        let nameIconStack = UIStackView(arrangedSubviews: [iconView, nameLabel])
        nameIconStack.axis = .horizontal
        nameIconStack.spacing = 16
        nameIconStack.alignment = .center
        
        let mainVStack = UIStackView(arrangedSubviews: [nameIconStack, progressLabel, progressBar])
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        mainVStack.axis = .vertical
        mainVStack.spacing = 10
        
        goalProgressCardView.addSubview(mainVStack)
        
        NSLayoutConstraint.activate([
            goalProgressCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            goalProgressCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            goalProgressCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            mainVStack.topAnchor.constraint(equalTo: goalProgressCardView.topAnchor, constant: 20),
            mainVStack.leadingAnchor.constraint(equalTo: goalProgressCardView.leadingAnchor, constant: 20),
            mainVStack.trailingAnchor.constraint(equalTo: goalProgressCardView.trailingAnchor, constant: -20),
            mainVStack.bottomAnchor.constraint(equalTo: goalProgressCardView.bottomAnchor, constant: -20),
            
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),
            progressBar.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setupTableView() {
        tableView.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "emptyCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: goalProgressCardView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// This function populates the UI elements in the top card
    private func refreshGoalProgressData() {
        guard let goal = self.goal else { return }
        
        let isCompleted = goal.savedAmount >= goal.targetAmount
        
        if isCompleted {
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
            iconView.tintColor = .systemGreen
            
            let attributedName = NSAttributedString(
                string: goal.name,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            nameLabel.attributedText = attributedName
            nameLabel.textColor = .secondaryLabel
            
            let total = CurrencyFormatter.shared.string(from: goal.targetAmount)
            progressLabel.text = "Completed! \(total)"
            
            progressBar.progress = 1.0
            progressBar.progressTintColor = .systemGreen
            
        } else {
            iconView.image = UIImage(systemName: goal.iconName)
            iconView.tintColor = .systemBlue
            
            nameLabel.text = goal.name
            nameLabel.textColor = .label
            
            let saved = CurrencyFormatter.shared.string(from: goal.savedAmount)
            let total = CurrencyFormatter.shared.string(from: goal.targetAmount)
            progressLabel.text = "\(saved) / \(total)"
            
            var progress: Float = 0.0
            if goal.targetAmount > 0 {
                progress = (NSDecimalNumber(decimal: goal.savedAmount).floatValue) / (NSDecimalNumber(decimal: goal.targetAmount).floatValue)
            }
            
            progressBar.progress = min(progress, 1.0)
            progressBar.progressTintColor = .systemBlue
        }
    }
    
    
    private func setupNavBarButtons() {
        let moreButton = UIBarButtonItem(
             image: UIImage(systemName: "ellipsis.circle"),
             style: .plain,
             target: self,
             action: nil
         )
         
         let editAction = UIAction(title: "Edit Goal", image: UIImage(systemName: "pencil")) { [weak self] _ in
             self?.editGoalTapped()
         }
         
         let deleteAction = UIAction(title: "Delete Goal", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
             self?.deleteGoalTapped()
         }
         
         moreButton.menu = UIMenu(title: "", children: [editAction, deleteAction])
         navigationItem.rightBarButtonItem = moreButton
    }
    
    private func editGoalTapped() {
        guard let goal = self.goal else { return }
        
        let goalVC = SavingGoalFormController()
        goalVC.delegate = self
        goalVC.goalToEdit = goal
        let navController = UINavigationController(rootViewController: goalVC)
        present(navController, animated: true)
    }

    private func deleteGoalTapped() {
        guard let goal = self.goal else { return }
        
        let alert = UIAlertController(title: "Delete \(goal.name)?", message: "Are you sure you want to delete this goal? This action cannot be undone.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.savingGoalStore.deleteSavingGoal(goal)
            self?.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension SavingGoalDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactions.isEmpty {
            return 1
        }
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if transactions.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "No contributions found for this goal."
            content.textProperties.color = .secondaryLabel
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as? ExpenseTableViewCell else {
            return UITableViewCell()
        }
        
        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contributions"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SavingGoalFormControllerDelegate
extension SavingGoalDetailViewController: SavingGoalFormControllerDelegate {
    
    func savingGoalFormController(_ controller: SavingGoalFormController, didSaveNew goal: SavingGoal) {
        savingGoalStore.addSavingGoal(goal)
        controller.dismiss(animated: true)
    }
    
    func savingGoalFormController(_ controller: SavingGoalFormController, didUpdate goal: SavingGoal) {
        savingGoalStore.updateSavingGoal(goal)
        
        self.goal = goal
        
        self.title = goal.name
        self.refreshGoalProgressData()
        
        controller.dismiss(animated: true)
    }
    
    func savingGoalFormControllerDidCancel(_ controller: SavingGoalFormController) {
        controller.dismiss(animated: true)
    }
}
