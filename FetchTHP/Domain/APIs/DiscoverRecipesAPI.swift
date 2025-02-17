//
//  DiscoverRecipesAPI.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

protocol DiscoverRecipesAPI {
    func fetch() async throws -> [Recipe]
}
