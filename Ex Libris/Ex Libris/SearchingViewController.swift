//
//  SearchingViewController.swift
//  Ex Libris
//
//  Created by Becky on 2/9/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit

let displaySearchResultsSegue = "displaySearchResultsSegue"
let unwindToBookListFromSearchingSegue = "unwindToBookListFromSearchingSegue"

class SearchingViewController: UIViewController {
	var barcodeToSearch: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let barcode = barcodeToSearch
			else {return}
		
		sendBarcodeToGoodreads(barcode) { (searchResults, error) in
			if let searchResults = searchResults {
				self.performSegue(withIdentifier: displaySearchResultsSegue,
				                  sender: searchResults)
			} else if let error = error {
				self.displayErrorAlert(errorMessage: error.localizedDescription)
			}
		}
	}
	
	func sendBarcodeToGoodreads(_ barcode: String, _ completion:((_ response: [SearchResult]?, _ error: Error?) -> Void)?) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		do {
			try appDelegate.network.getResultsForSearch(barcode, completion: completion)
		} catch NetworkingControllerError.notLoggedIn {
			displayErrorAlert(errorMessage: "Not logged in.")
		} catch {
			displayErrorAlert(errorMessage: "Unknown error.")
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == displaySearchResultsSegue {
			guard let searchResultsNavVC = segue.destination as? UINavigationController
				else {return}
			
			guard let searchResultsVC = searchResultsNavVC.topViewController as? SearchResultsTableViewController
				else {return}
			
			guard let searchResults = sender as? [SearchResult]
				else {return}
			
			searchResultsVC.searchResults = searchResults
		}
	}

	func displayErrorAlert(errorMessage: String) {
		let alert = UIAlertController.init(title: "There was an error searching for this barcode on Goodreads.",
		                                   message: "Error message: \(errorMessage)",
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
