//
//  LoginViewController.swift
//  Ex Libris
//
//  Created by Becky on 2/7/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit

let loggedInSegue = "loggedIn"

extension Notification.Name {
	static let loginComplete = Notification.Name(rawValue: "loginComplete")
}

class LoginViewController: UIViewController {
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(LoginViewController.loginFinished),
		                                       name: NSNotification.Name.loginComplete,
		                                       object: nil)
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.network.oauthLogin()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, forKeyPath: Notification.Name.loginComplete.rawValue)
	}
	
	func loginFinished() throws {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		try appDelegate.network.getAllBooks { (response, error) in
			self.performSegue(withIdentifier: loggedInSegue,
			                  sender: response)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == loggedInSegue {
			guard let destination = segue.destination as? TabBarController
				else {return}
			
			guard let bookList = sender as? [Book]
				else {return}
			
			destination.bookList = bookList
		}
	}
}
