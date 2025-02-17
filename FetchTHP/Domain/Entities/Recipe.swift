//
//  Recipe.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

struct RecipeResponse: Codable {
    var recipes: [Recipe]
}

struct Recipe: Hashable, Codable {
    var id: UUID
    var cuisine: String
    var name: String
    var photoURL: URL?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine
        case name
        case photoURL = "photo_url_small"
    }
}

#if DEBUG
extension Recipe {
    static var sample: Recipe {
        return Recipe(
            id: UUID(),
            cuisine: "American",
            name: "Salted Caramel Cheescake",
            photoURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b75ee8ef-a290-4062-8b26-60722d75d09c/small.jpg")!
        )
    }
}
#endif
