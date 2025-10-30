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
        let preferenceViewController = PreferenceViewController()
        
        dashboardViewController.tabBarItem = UITabBarItem(title: "Overview", image: UIImage(systemName: "chart.pie") , tag: 0)
        expenseListViewController.tabBarItem = UITabBarItem(title: "Expenses", image: UIImage(systemName: "dollarsign.square"), tag: 1)
        preferenceViewController.tabBarItem = UITabBarItem(title: "Preference", image: UIImage(systemName: "gearshape"), tag: 2)
        
        let dashboardNavigationController = createNavigationController(for: dashboardViewController)
        let expenseNavigationController = createNavigationController(for: expenseListViewController)
        let preferenceNavigationController = createNavigationController(for: preferenceViewController)
        
        
        self.viewControllers = [
            dashboardNavigationController,
            expenseNavigationController,
            preferenceNavigationController
        ]

    }
    
    private func createNavigationController(for rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)

        return navigationController
    }

}
