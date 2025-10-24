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
    
    private var isSearching: Bool {
        let hasText = !(searchController.searchBar.text?.isEmpty ?? true)
        let hasScope = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (hasText || hasScope)
    }
    
    private var scopeTitles: [String] = ["All"] + ExpenseType.allCases.map { $0.rawValue.capitalized }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "No money 💰"
        navigationItem.largeTitleDisplayMode = .always
        
        
        setupDiffableDataSource()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
        object: nil, queue: .main) { [weak self] _ in
                guard let self else { return }
                try? self.store.saveExpenses(self.allExpenses)
        }
        
        
        setupSearchController()
        
        allExpenses = store.loadExpenses()
        applySnapshot()
        
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource<ExpenseType, Expense>(tableView: expenseTableView) {
            // Add the explicit type for 'item' here
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
    
    private func setupSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.searchBar.delegate = self
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<ExpenseType, Expense>()

        let current = isSearching ? filteredExpenses : allExpenses
        
        // Group items by type (1)
        let grouped = Dictionary(grouping: current, by: { $0.type })

        // Sort types alphabetically (1)
        let sortedTypes = grouped.keys.sorted(by: { $0.rawValue < $1.rawValue })

        // Build snapshot
        snapshot.appendSections(sortedTypes)
        for type in sortedTypes {
            // (2) Force unwrap!
            snapshot.appendItems(grouped[type]!, toSection: type)
        }

            // Apply it to the data source
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        updateBackgroundMessage()
    }
    
    private func setupNavigationBar(){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .brown
        
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 30)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30, weight: .semibold)]
        
        // add button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewExpense))
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
    
    private func setupTableView() {
        expenseTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(expenseTableView)
        
        NSLayoutConstraint.activate([
            expenseTableView.topAnchor.constraint(equalTo: view.topAnchor),
            expenseTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expenseTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expenseTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        
        expenseTableView.delegate = self
        expenseTableView.rowHeight = UITableView.automaticDimension
        expenseTableView.register(ExpenseTableViewCell.self, forCellReuseIdentifier: ExpenseTableViewCell.identifier)
    }
    
    // MARK: Helper
    
    @objc private func addNewExpense(){
        // TODO: add new expense
        let addVC = ExpenseFormController()
        addVC.delegate = self
        let navController = UINavigationController(rootViewController: addVC)
        present(navController, animated: true)
    }
    
    private func updateBackgroundMessage() {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        if allExpenses.isEmpty {
            label.text = "No expenses yet"
        } else if isSearching && filteredExpenses.isEmpty {
            label.text = "No results."
        } else {
            expenseTableView.backgroundView = nil
            return
        }
        expenseTableView.backgroundView = label
    }
}

extension ListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tappedExpense = dataSource.itemIdentifier(for: indexPath) else {return}
        
        let detailVC = ExpenseDetailViewController(expense: tappedExpense, index: indexPath.row)
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // TODO: check if expense has image, and adjust height accordingly
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard let expenseToDelete = dataSource.itemIdentifier(for: indexPath) else { return }
        allExpenses.removeAll { $0.id == expenseToDelete.id }
        store.saveExpenses(allExpenses)
        applySnapshot()
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        guard let expense = dataSource.itemIdentifier(for: indexPath) else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_,done in
            self.allExpenses.removeAll { $0.id == expense.id }
            self.store.saveExpenses(self.allExpenses)
            self.applySnapshot()
            done(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

extension ListViewController: ExpenseFormControllerDelegate{
    func didAddExpense(_ expense: Expense) {
        allExpenses.append(expense)
        store.saveExpenses(allExpenses)
        applySnapshot()
    }
}

extension ListViewController: ExpenseDetailViewControllerDelegate{
    func didFinishEditing(expense updatedExpense: Expense) {
        if let index = allExpenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            allExpenses[index] = updatedExpense
            
            store.saveExpenses(allExpenses)
            applySnapshot()
        }
    }
}

extension ListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {

        var filtered = allExpenses
        // by scope
        let selectedScopeIndex = searchController.searchBar.selectedScopeButtonIndex
        if selectedScopeIndex > 0{
            let expenseType = ExpenseType.allCases[selectedScopeIndex - 1]
            filtered = filtered.filter {$0.type == expenseType}
            
        }
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            filtered = filtered.filter { expense in
                expense.name.lowercased().contains(searchText.lowercased())
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsScopeBar = false
    }
}
