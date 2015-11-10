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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Try to fix the bug when the search bar active, move back from the other tab will cause black screen
//    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//        let nav = viewController as! UINavigationController
//        nav.popToRootViewControllerAnimated(true)
//        
//        if (tabBarController.selectedIndex == 0) {
//            let eventNav = viewController as! UINavigationController
//            let eventView = eventNav.viewControllers[0] as! EventTableViewController
//            eventView.searchController.active = false
//        }
//    }
}
