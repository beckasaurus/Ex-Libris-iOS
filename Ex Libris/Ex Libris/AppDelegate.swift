//
//  AppDelegate.swift
//  Ex Libris
//
//  Created by Becky Henderson on 2/6/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var network: NetworkingController
	
	override init() {
		network = NetworkingController.init()
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		return true
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		if (url.host == "oauth-callback") {
			OAuthSwift.handle(url: url)
		}
		return true
	}
}

