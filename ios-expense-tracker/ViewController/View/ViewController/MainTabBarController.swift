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
        let dashboardViewController = DashboardViewController()
        let expenseListViewController = ListViewController()
//        let preferencesViewController = PreferencesViewController()
        
        dashboardViewController.tabBarItem = UITabBarItem(title: "Overview", image: UIImage(systemName: "chart.pie") , tag: 0)
        expenseListViewController.tabBarItem = UITabBarItem(title: "Expenses", image: UIImage(systemName: "dollarsign.square"), tag: 1)
        
        let dashboardNavigationController = createNavigationController(for: dashboardViewController)
        let expenseNavigationController = createNavigationController(for: expenseListViewController)
        
        
        self.viewControllers = [
            dashboardNavigationController,
            expenseNavigationController
        ]

    }
    
    private func createNavigationController(for rootViewController: UIViewController) -> UINavigationController {
        // Create navigation controller with this view controller as root
        let navigationController = UINavigationController(rootViewController: rootViewController)

        return navigationController
    }

}
