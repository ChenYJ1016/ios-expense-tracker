//
//  MainTabBarController.swift
//  ios-expense-tracker
//
//  Created by James Chen on 24/10/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpTabBar()
    }
     
    private func setUpTabBar(){
//        let dashboardViewController = DashBoardViewVController()
        let expenseListViewController = ListViewController()
//        let preferencesViewController = PreferencesViewController()
        
        expenseListViewController.tabBarItem = UITabBarItem(title: "Expenses", image: UIImage(systemName: "dollarsign.square"), tag: 0)
        
        let expenseNavigationController = createNavigationController(for: expenseListViewController)
        
        self.viewControllers = [expenseNavigationController]

    }
    
    private func createNavigationController(for rootViewController: UIViewController) -> UINavigationController {
        // Create navigation controller with this view controller as root
        let navigationController = UINavigationController(rootViewController: rootViewController)
//        navigationController.navigationBar.prefersLargeTitles = true

        return navigationController
    }

}
