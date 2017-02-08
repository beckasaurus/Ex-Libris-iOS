//
//  TabBarController.swift
//  Ex Libris
//
//  Created by Becky on 2/7/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
	var bookList = [Book]() {
		didSet {
			if let viewControllers = viewControllers {
				for navigationController in viewControllers {
					guard let navigationController = navigationController as? UINavigationController
						else {continue}
					
					guard let bookViewController = navigationController.topViewController as? BookListTableViewController
						else {continue}
					
					bookViewController.bookList = bookList
				}
			}
		}
	}
}
