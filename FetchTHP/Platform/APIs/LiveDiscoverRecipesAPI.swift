//
//  LiveDiscoverRecipesAPI.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

final class LiveDiscoverRecipesAPI: DiscoverRecipesAPI {
    private let client: DataFetching
    private let decoder = JSONDecoder()

    init(client: DataFetching) {
        self.client = client
    }

    func fetch() async throws -> [Recipe] {
        do {
            let resource = Resource(path: "recipes.json")
            let data = try await client.fetch(resource: resource)
            let response = try decoder.decode(RecipeResponse.self, from: data)

            return response.recipes
        } catch let error as NetworkError {
            if case .notConnectedToInternet = error {
                throw OfflineError()
            }

            throw error
        } catch {
            throw error
        }
    }
}
