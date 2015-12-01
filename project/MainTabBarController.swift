//
//  MainTabBarController.swift
//  project
//
//  Created by Thanh Nguyen on 11/3/15.
//  Copyright © 2015 thanhcs. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        UITabBar.appearance().barTintColor = UIColor.orangeColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let nav = viewController as! UINavigationController
        nav.popToRootViewControllerAnimated(false)
        
        // Try to fix the bug when the search bar active, move back from the other tab will cause black screen
//        if (tabBarController.selectedIndex == 0) {
//            let eventNav = viewController as! UINavigationController
//            let eventView = eventNav.viewControllers[0] as! EventTableViewController
//            eventView.searchController.active = false
//        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
