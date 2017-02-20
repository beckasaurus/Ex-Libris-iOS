//
//  SearchResultsTableViewController.swift
//  Ex Libris
//
//  Created by Becky on 2/9/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit

let addedBookToLibrarySegue = "addedBookToLibrarySegue"

class SearchResultsTableViewController: UITableViewController {
	var searchResults: [SearchResult] = [] {
		didSet {
			self.tableView.reloadData()
		}
	}
	
	@IBAction func save(_ sender: Any) {
		guard let selectedIndexPath = self.tableView.indexPathForSelectedRow
			else {return}
		
		guard let selectedIndex = selectedIndexPath.first
			else {return}
		
		let selectedResult = searchResults[selectedIndex]
		
		addToGoodreadsLibrary(selectedResult) { (success, error) in
			if (success) {
				self.displayAlert(title: "Yay", message: "cool")
			} else if let error = error {
				self.displayErrorAlert(errorMessage: error.localizedDescription)
			} else {
				self.displayErrorAlert(errorMessage: "Unknown error.")
			}
			
			self.performSegue(withIdentifier: addedBookToLibrarySegue, sender: nil)
		}
	}
	
	func addToGoodreadsLibrary(_ searchResult: SearchResult, _ completion:((_ response: Bool, _ error: Error?) -> Void)?) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		do {
			try appDelegate.network.addBookToLibrary(searchResult, completion: completion)
		} catch NetworkingControllerError.notLoggedIn {
			displayErrorAlert(errorMessage: "Not logged in.")
		} catch {
			displayErrorAlert(errorMessage: "Unknown error.")
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier:"searchResultsCell", for: indexPath)
		
		cell.textLabel?.text = searchResults[indexPath.row].title
		cell.detailTextLabel?.text = searchResults[indexPath.row].author
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults.count
	}

	func displayErrorAlert(errorMessage: String) {
		let title = "There was an error searching for this barcode on Goodreads."
		let message = "Error message: \(errorMessage)"
		displayAlert(title: title, message: message)
	}
	
	func displayAlert(title: String, message: String) {
		let alert = UIAlertController.init(title: title,
		                                   message: message,
			preferredStyle:.alert)
		
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
			(result : UIAlertAction) -> Void in
			print("OK")
		}
		
		alert.addAction(okAction)
		
		self.present(alert, animated: true) {
			self.performSegue(withIdentifier: unwindToBookListFromSearchingSegue,
			                  sender: nil)
		}
	}
}
