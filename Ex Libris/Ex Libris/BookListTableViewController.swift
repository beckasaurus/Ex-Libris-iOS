//
//  BookListTableViewController.swift
//  Ex Libris
//
//  Created by Becky Henderson on 2/6/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit
import OAuthSwift

class BookListTableViewController: UITableViewController {
	
	var bookList: [Book] = []
	
	@IBAction func addNewBook(_ sender: Any) {
		//search sheet
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier:"bookListCell", for: indexPath)
		
		cell.textLabel?.text = bookList[indexPath.row].title
		cell.detailTextLabel?.text = bookList[indexPath.row].author
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return bookList.count
	}
}
