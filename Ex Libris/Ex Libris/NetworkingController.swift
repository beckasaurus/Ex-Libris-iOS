//
//  NetworkingController.swift
//  Ex Libris
//
//  Created by Becky on 2/7/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import OAuthSwift
import OAuthSwiftAlamofire
import Alamofire
import SWXMLHash

let developerKey: String = "JMV5PbTi1UI3tax74ChqTQ"
let secretKey: String = "qFDjxMXQBww9GyNTvH0Y6kdbkAmijcRtSUSE6iTsHhM"
let basePath: String = "http://www.goodreads.com"

enum NetworkingControllerError: Error {
	case errorInitializingOauthSwift
	case notLoggedIn
}

class NetworkingController {
	
	var oauthSwift: OAuth1Swift
	var sessionManager: SessionManager
	
	var goodreadsUserId: String?
	
	init() {
		oauthSwift = OAuth1Swift(
			consumerKey:    developerKey,
			consumerSecret: secretKey,
			requestTokenUrl: basePath + "/oauth/request_token",
			authorizeUrl:    basePath + "/oauth/authorize?mobile=1",
			accessTokenUrl:  basePath + "/oauth/access_token")
		oauthSwift.allowMissingOAuthVerifier = true
		
		sessionManager = SessionManager.default
	}
	
	func oauthLogin() {
		oauthSwift.authorize(
			withCallbackURL: URL(string: "exlibris://oauth-callback/goodreads")!,
			success: { credential, response, parameters in
				self.sessionManager.adapter = self.oauthSwift.requestAdapter
				self.getGoodreadsUserId({ (response, error) in
					if let response = response {
						if let userId = response["user"].element?.attribute(by: "id")?.text {
							self.goodreadsUserId = userId
							NotificationCenter.default.post(name: .loginComplete, object: nil)
						}
					}
				})
			},
			failure: { error in
				print(error.localizedDescription)
		})
	}
	
	func getRequest(_ path: String, params: [String:Any]?, completion:@escaping (_ response: XMLIndexer?, _ error: Error?) -> Void) {
		sessionManager.request(basePath + path, parameters: params).response { (response) in
			if let data = response.data {
				let response = SWXMLHash.parse(data)
				completion(response["GoodreadsResponse"], nil)
			}
		}
	}
	
	func postRequest(_ path: String, params: [String:Any]?, completion:@escaping (_ response: Bool, _ error: Error?) -> Void) {
		sessionManager.request(basePath + path, method: .post, parameters: params, encoding: URLEncoding.default,
		                       headers: ["Accept" : "application/xml"]).response { (requestResponse) in
			if requestResponse.data != nil {
				completion(true, nil)
			}
		}
	}
}

private typealias GoodreadsRequests = NetworkingController
extension GoodreadsRequests {
	func getGoodreadsUserId(_ completion:((_ response: XMLIndexer?, _ error: Error?) -> Void)?) {
		getRequest("/api/auth_user", params: nil) { (response, error) in
			if let response = response {
				completion?(response, nil)
			}
		}
	}
	
	func getAllBooks(_ completion:((_ response: [Book]?, _ error: Error?) -> Void)?) throws {
		guard let goodreadsUserId = goodreadsUserId
			else {throw NetworkingControllerError.notLoggedIn}
		
		getRequest("/owned_books/user", params: ["format" : "xml", "id" : goodreadsUserId]) { (response, error) in
			if let response = response {
				var ownedBooks = [Book]()
				
				for ownedBookResponse in response["owned_books"]["owned_book"] {
					do {
						let book = try Book.init(response: ownedBookResponse)
						ownedBooks.append(book)
					} catch {
						print("Invalid book.")
					}
				}
				
				completion?(ownedBooks, nil)
			} else {
				completion?(nil, error)
			}
		}
	}
	
	func getResultsForSearch(_ upc: String, completion:((_ response: [SearchResult]?, _ error: Error?) -> Void)?) throws {
		guard let _ = goodreadsUserId
			else {throw NetworkingControllerError.notLoggedIn}
				
		getRequest("/search/index.xml", params: ["q":upc]) { (response, error) in
			if let response = response {
			var results = [SearchResult]()
			
			for work in response["search"]["results"]["work"] {
				do {
					let searchResult = try SearchResult.init(response: work["best_book"])
					results.append(searchResult)
				} catch {
					completion?(nil, NSError.init(domain: "Ex Libris", code: 1, userInfo: ["localizedDescription" : "Error getting search results from Goodreads."]))
				}
			}
			
			completion?(results, nil)
			} else {
				completion?(nil, error)
			}
		}
	}
	
	func addBookToLibrary(_ searchResult: SearchResult, completion:((_ response: Bool, _ error: Error?) -> Void)?) throws {
		guard let _ = goodreadsUserId
			else {throw NetworkingControllerError.notLoggedIn}
		
		postRequest("/owned_books.xml", params: ["owned_book[book_id]":searchResult.id]) { (response, error) in
			completion?(response, error)
		}
	}
}
