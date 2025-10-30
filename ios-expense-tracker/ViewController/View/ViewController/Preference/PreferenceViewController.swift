//
//  PreferenceViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 30/10/25.
//
import UIKit

class PreferenceViewController: UIViewController {

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
        return tv
    }()
    
    // MARK: - Data Stores
    private let expenseStore = ExpenseDataStore.shared
    private let budgetStore = BudgetDataStore.shared
    private let savingGoalStore = SavingGoalDataStore.shared
    
    // MARK: - Appearance Storage
    
    private var selectedAppearance: UIUserInterfaceStyle {
        get {
            let storedValue = UserDefaults.standard.integer(forKey: "appAppearance")
            return UIUserInterfaceStyle(rawValue: storedValue) ?? .unspecified
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appAppearance")
            applyAppearance(newValue)
        }
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preferences"
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
    }
    
    // MARK: - UI Setup
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Applies the selected appearance to the entire app's window
    private func applyAppearance(_ appearance: UIUserInterfaceStyle) {
        view.window?.overrideUserInterfaceStyle = appearance
    }
}

// MARK: - UITableViewDataSource & Delegate
extension PreferenceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Appearance"
        } else {
            return "Data Management"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        cell.accessoryType = .none
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                content.text = "Light"
                if selectedAppearance == .light {
                    cell.accessoryType = .checkmark
                }
            case 1:
                content.text = "Dark"
                if selectedAppearance == .dark {
                    cell.accessoryType = .checkmark
                }
            case 2:
                content.text = "System"
                if selectedAppearance == .unspecified {
                    cell.accessoryType = .checkmark
                }
            default:
                break
            }
        } else {
            content.text = "Delete All Data"
            content.textProperties.color = .systemRed
            content.textProperties.alignment = .center
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                selectedAppearance = .light
            case 1:
                selectedAppearance = .dark
            case 2:
                selectedAppearance = .unspecified
            default:
                break
            }
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
            
        } else {
            showDeleteDataConfirmation()
        }
    }
}

// MARK: - Data Management
extension PreferenceViewController {
    
    private func showDeleteDataConfirmation() {
        let alert = UIAlertController(
            title: "Delete All Data?",
            message: "Are you sure you want to delete all expenses, budgets, and saving goals? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteAllData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    private func deleteAllData() {
        expenseStore.deleteAllExpenses()
        budgetStore.deleteBudget()
        savingGoalStore.deleteAllSavingGoals()
        
        print("All data deleted.")
        
        showDeleteSuccessAlert()
    }
    
    private func showDeleteSuccessAlert() {
        let alert = UIAlertController(
            title: "Success",
            message: "All app data has been deleted.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
