//
//  Book.swift
//  Ex Libris
//
//  Created by Becky on 2/7/17.
//  Copyright © 2017 Beckasaurus Productions. All rights reserved.
//

import SWXMLHash

enum BookError: Error {
	case invalidResponse
}

struct Book {
	let title: String
	let author: String
	let description: String
	
	init(response: XMLIndexer) throws {
		guard let responseTitle = response["book"]["title"].element?.text
			else {throw BookError.invalidResponse}
		
		title = responseTitle
		
		guard let responseAuthor = response["book"]["authors"]["author"][0]["name"].element?.text
			else {throw BookError.invalidResponse}
		
		author = responseAuthor
		
		guard let responseDescription = response["book"]["description"].element?.text
			else {throw BookError.invalidResponse}
		
		description = responseDescription
	}
}
