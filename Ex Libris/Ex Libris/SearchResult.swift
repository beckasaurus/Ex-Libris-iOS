//
//  SearchResult.swift
//  Ex Libris
//
//  Created by Becky Henderson on 2/8/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import SWXMLHash

enum SearchResultError: Error {
	case invalidResponse
}

struct SearchResult {
	let title: String
	let author: String
	let id: Int
	
	init(response: XMLIndexer) throws {
		guard let responseTitle = response["title"].element?.text
			else {throw SearchResultError.invalidResponse}
		
		title = responseTitle
		
		guard let responseAuthor = response["author"]["name"].element?.text
			else {throw SearchResultError.invalidResponse}
		
		author = responseAuthor
		
		guard let responseIdString = response["id"].element?.text
			else {throw SearchResultError.invalidResponse}
		
		guard let responseId = Int(responseIdString)
			else {throw SearchResultError.invalidResponse}
		
		id = responseId
	}
}
