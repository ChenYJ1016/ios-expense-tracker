//
//  ViewController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 10/10/25.
//

import UIKit

class ListViewController: UIViewController {

    
    var allExpenses: [Expense] = []
    // UIVIews
    let expenseTableView = UITableView()
    
    private let store = ExpenseDataStore.shared
    private var dataSource: UITableViewDiffableDataSource<ExpenseType, Expense>!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var filteredExpenses: [Expense] = []
    
    private var addButton: UIBarButtonItem!
    private var filterButton: UIBarButtonItem!
    
    private var dateFilterView: UIStackView!
    private var dateFilterButton: UIButton!
    private var dateFilterLabel: UILabel!
    
    private var currentStartDate: Date?
    private var currentEndDate: Date?
    
    private var isSearching: Bool {
        let hasText = !(searchController.searchBar.text?.isEmpty ?? true)
        let hasScope = searchController.searchBar.selectedScopeButtonIndex != 0
        let hasDateFilter = currentStartDate != nil || currentEndDate != nil
        
        return searchController.isActive || hasText || hasScope || hasDateFilter
    }
    
    private var scopeTitles: [String] = ["All"] + ExpenseType.allCases.map { $0.rawValue }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Expenses"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataDidChange),
            name: .didUpdateExpenses,
            object: nil
        )
        
        setupNavigationBar()
        setupSearchController()
        setupDateFilterView()

        setupTableView()

        setupDiffableDataSource()
        allExpenses = store.loadExpenses()
        applySnapshot()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Expenses"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false

        
        searchController.delegate = self
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.searchBar.delegate = self
        searchController.searchBar.showsScopeBar = false
                
        searchController.searchBar.layoutIfNeeded()

        if let segmentedControl = searchController.searchBar.findSegmentedControl() {
            for (index, type) in ExpenseType.allCases.enumerated() {
                if let icon = UIImage(systemName: type.iconName) {
                    segmentedControl.setImage(icon, forSegmentAt: index + 1)
                }
            }
        }
    }
    
    
    private func setupDateFilterView() {
            dateFilterLabel = UILabel()
            dateFilterLabel.text = "Filter by Date Range"
            dateFilterLabel.font = .preferredFont(forTextStyle: .subheadline)
            
            dateFilterButton = UIButton(type: .system)
            dateFilterButton.setTitle("None ", for: .normal)
            dateFilterButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            dateFilterButton.semanticContentAttribute = .forceRightToLeft
            dateFilterButton.addTarget(self, action: #selector(selectDateTapped), for: .touchUpInside)
            
            dateFilterView = UIStackView(arrangedSubviews: [dateFilterLabel, dateFilterButton])
            dateFilterView.axis = .horizontal
            dateFilterView.spacing = 8
            dateFilterView.alignment = .center
            dateFilterView.isLayoutMarginsRelativeArrangement = true
            dateFilterView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            dateFilterView.backgroundColor = .systemGray6
            
            dateFilterView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dateFilterView)
            
            dateFilterView.isHidden = true
            
            NSLayoutConstraint.activate([
                dateFilterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                dateFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dateFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
        }
    
    @objc private func selectDateTapped() {
            let dateFilterVC = DateFilterViewController()
            
            dateFilterVC.delegate = self
            dateFilterVC.currentStartDate = self.currentStartDate
            dateFilterVC.currentEndDate = self.currentEndDate
            
            if let sheet = dateFilterVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            present(dateFilterVC, animated: true)
        }
        
        private func updateDateFilterButtonLabel() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            
            if let startDate = currentStartDate, let endDate = currentEndDate {
                let startString = formatter.string(from: startDate)
                let endString = formatter.string(from: endDate)
                dateFilterButton.setTitle("\(startString) - \(endString) ", for: .normal)
            } else {
                dateFilterButton.setTitle("None ", for: .normal)
            }
        }
    
    private func setupNavigationBar(){
        
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewExpense))
        let filterIcon = UIImage(systemName: "line.3.horizontal.decrease.circle")
        filterButton = UIBarButtonItem(image: filterIcon, style: .plain, target: self, action: #selector(filterButtonTapped))
        
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        expenseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(expenseTableView)
        
        NSLayoutConstraint.activate([
            expenseTableView.topAnchor.constraint(equalTo: dateFilterView.bottomAnchor),
            expenseTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expenseTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expenseTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        expenseTableView.delegate = self
        expenseTableView.rowHeight = UITableView.automaticDimension
        expenseTableView.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
    }
    
    // MARK: Helper
    
    @objc private func dataDidChange() {
        allExpenses = store.loadExpenses()
        
        if isSearching {
            updateSearchResults(for: searchController)
        } else {
            applySnapshot()
        }
    }
    
    @objc private func addNewExpense(){
        let addVC = ExpenseFormController()
        addVC.delegate = self
        let navController = UINavigationController(rootViewController: addVC)
        present(navController, animated: true)
    }
    
    private func updateBackgroundMessage() {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let list = isSearching ? filteredExpenses : allExpenses
        
        if allExpenses.isEmpty {
            label.text = "No expenses yet"
        } else if list.isEmpty {
            label.text = "No results."
        } else {
            expenseTableView.backgroundView = nil
            return
        }
        expenseTableView.backgroundView = label
    }
    
    @objc private func filterButtonTapped(){
        if searchController.isActive {
            UIView.animate(withDuration: 0.3) {
                self.searchController.searchBar.showsScopeBar.toggle()
                self.searchController.searchBar.sizeToFit()
            }
            self.dateFilterView.isHidden.toggle()

        }
    }
    
    private func showDeleteConfirmationAlert(for expense: Expense) {
        let alert = UIAlertController(
            title: "Delete Expense?",
            message: "Are you sure you want to delete '\(expense.name)'? This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
         
            self.store.deleteExpense(expense)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
}

extension ListViewController{
    private func setupDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource<ExpenseType, Expense>(tableView: expenseTableView) {
            tableView, indexPath, item in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseTableViewCell.identifier, for: indexPath) as? ExpenseTableViewCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            return cell
        }
        
        dataSource.defaultRowAnimation = .fade
        expenseTableView.dataSource = dataSource
        expenseTableView.delegate = self
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<ExpenseType, Expense>()

        let current = isSearching ? filteredExpenses : allExpenses
        
        let grouped = Dictionary(grouping: current, by: { $0.type })
        let sortedTypes = grouped.keys.sorted(by: { $0.rawValue < $1.rawValue })

        snapshot.appendSections(sortedTypes)
        for type in sortedTypes {
            snapshot.appendItems(grouped[type]!, toSection: type)
        }

        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        updateBackgroundMessage()
    }
}

extension UIView {
    func findSegmentedControl() -> UISegmentedControl? {
        for subview in self.subviews {
            if let segmentedControl = subview as? UISegmentedControl {
                return segmentedControl
            }
        }
        
        for subview in self.subviews {
            if let segmentedControl = subview.findSegmentedControl() {
                return segmentedControl
            }
        }
        
        return nil
    }
}

extension ListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tappedExpense = dataSource.itemIdentifier(for: indexPath) else {return}
                
        let detailVC = ExpenseDetailViewController(expense: tappedExpense)
        detailVC.delegate = self
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let expenseToDelete = dataSource.itemIdentifier(for: indexPath) else { return }
            showDeleteConfirmationAlert(for: expenseToDelete)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        guard let expense = dataSource.itemIdentifier(for: indexPath) else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
            self?.showDeleteConfirmationAlert(for: expense)
            
            done(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: - ExpenseFormControllerDelegate
extension ListViewController: ExpenseFormControllerDelegate {
    
    func expenseFormController(didSave expense: Expense, controller: ExpenseFormController) {
        controller.dismiss(animated: true)
    }
    
    func expenseFormControllerDidCancel(controller: ExpenseFormController) {
        controller.dismiss(animated: true)
    }
}

extension ListViewController: ExpenseDetailViewControllerDelegate{
    func didFinishEditing(expense updatedExpense: Expense) {
        store.updateExpense(updatedExpense)
    }
}

extension ListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {

            var filtered = allExpenses
            
            let selectedScopeIndex = searchController.searchBar.selectedScopeButtonIndex
            if selectedScopeIndex > 0 {
                let expenseType = ExpenseType.allCases[selectedScopeIndex - 1]
                filtered = filtered.filter {$0.type == expenseType}
            }
            
            if let searchText = searchController.searchBar.text, !searchText.isEmpty {
                filtered = filtered.filter { expense in
                    expense.name.lowercased().contains(searchText.lowercased())
                }
            }
            
            if let startDate = currentStartDate, let endDate = currentEndDate {

                let startOfDay = Calendar.current.startOfDay(for: startDate)
                let endOfDay = Calendar.current.startOfDay(for: endDate).addingTimeInterval(24*60*60 - 1)

                filtered = filtered.filter { expense in
                    return expense.date >= startOfDay && expense.date <= endOfDay
                }
            }
            
            self.filteredExpenses = filtered
            applySnapshot()
        }

}

extension ListViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
        
        currentStartDate = nil
        currentEndDate = nil
        updateDateFilterButtonLabel()
        
        UIView.animate(withDuration: 0.3) {
            self.dateFilterView.isHidden = true
        }
    }
}

extension ListViewController: UISearchControllerDelegate{
    func didPresentSearchController(_ searchController: UISearchController) {
        navigationItem.setRightBarButton(filterButton, animated: true)
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationItem.setRightBarButton(addButton, animated: true)
        
        currentStartDate = nil
        currentEndDate = nil
        updateDateFilterButtonLabel()
        
        UIView.animate(withDuration: 0.3) {
            self.searchController.searchBar.showsScopeBar = false
            self.dateFilterView.isHidden = true
        }
    }
}

extension ListViewController: DateFilterViewControllerDelegate {
    
    func didApplyDateFilter(startDate: Date?, endDate: Date?) {

        self.currentStartDate = startDate
        self.currentEndDate = endDate
        
        updateDateFilterButtonLabel()
        
        updateSearchResults(for: searchController)
    }
}

