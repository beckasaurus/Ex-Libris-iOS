//
//  UnreadBookListTableViewController.swift
//  Ex Libris
//
//  Created by Becky on 2/7/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

class UnreadBookListTableViewController: BookListTableViewController {
	override func tableCellIdentifier() -> String {
		return "UnreadBookListCell"
	}
}
