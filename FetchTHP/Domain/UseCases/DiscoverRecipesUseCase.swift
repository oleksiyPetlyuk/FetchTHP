//
//  DiscoverRecipesUseCase.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

protocol DiscoverRecipesUseCase {
    func fetch(sortBy: DiscoverRecipesSortBy) async throws -> [Recipe]
}

enum DiscoverRecipesSortBy: CaseIterable {
    case name
    case cuisine
}

final class LiveDiscoverRecipesUseCase: DiscoverRecipesUseCase {
    private let api: DiscoverRecipesAPI

    init(api: DiscoverRecipesAPI) {
        self.api = api
    }

    func fetch(sortBy: DiscoverRecipesSortBy) async throws -> [Recipe] {
        do {
            let recipes = try await api.fetch()

            switch sortBy {
            case .cuisine:
                return recipes.sorted { ($0.cuisine, $0.name) < ($1.cuisine, $1.name) }
            case .name:
                return recipes.sorted { $0.name < $1.name }
            }
        } catch {
            throw error
        }
    }
}

#if DEBUG
final class MockDiscoverRecipesUseCase: DiscoverRecipesUseCase {
    func fetch(sortBy: DiscoverRecipesSortBy) async throws -> [Recipe] {
        return [Recipe.sample, Recipe.sample, Recipe.sample]
    }
}
#endif
