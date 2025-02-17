//
//  Resource.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

struct Resource {
    let path: String
    let method: HTTPMethod
    let query: [String: String]

    init(path: String, method: HTTPMethod = .GET, query: [String : String] = [:]) {
        self.path = path
        self.method = method
        self.query = query
    }
}
