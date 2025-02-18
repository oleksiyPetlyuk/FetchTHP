//
//  DiscoverRecipesUseCaseTests.swift
//  FetchTHPTests
//
//  Created by Petlyuk, Oleksiy on 2/17/25.
//

import Testing
import Foundation
@testable import FetchTHP

struct DiscoverRecipesUseCaseTests {
    private let apiSpy: DiscoverRecipesAPISpy
    private let sut: LiveDiscoverRecipesUseCase

    init() {
        apiSpy = DiscoverRecipesAPISpy()
        sut = LiveDiscoverRecipesUseCase(api: apiSpy)
    }

    @Test func fetch_shouldReturnSortedRecipes() async throws {
        await #expect(throws: Never.self) {
            let recipes = [
                Recipe(id: UUID(), cuisine: "American", name: "Banana Pancakes"),
                Recipe(id: UUID(), cuisine: "American", name: "Chocolate Raspberry Brownies"),
                Recipe(id: UUID(), cuisine: "French", name: "Chocolate Souffle"),
                Recipe(id: UUID(), cuisine: "Greek", name: "Honey Yogurt Cheesecake"),
            ]
            apiSpy.fetchDataToBeReturned = { recipes.shuffled() }

            let resultSortedByName = try await sut.fetch(sortBy: .name)
            let resultSortedByCuisine = try await sut.fetch(sortBy: .cuisine)

            #expect(resultSortedByName == recipes.sorted { $0.name < $1.name })
            #expect(resultSortedByCuisine == recipes.sorted { $0.cuisine < $1.cuisine })
            #expect(apiSpy.fetchCalledCount == 2)
        }
    }

    @Test func fetch_shouldReThrowError() async throws {
        apiSpy.fetchDataToBeReturned = { throw NetworkError.cancelled }

        await #expect(throws: NetworkError.cancelled) {
            try await sut.fetch(sortBy: .name)
        }

        #expect(apiSpy.fetchCalledCount == 1)
    }
}

final class DiscoverRecipesAPISpy: DiscoverRecipesAPI {
    private(set) var fetchCalledCount = 0

    var fetchDataToBeReturned: () throws -> [Recipe] = { [] }

    func fetch() async throws -> [Recipe] {
        fetchCalledCount += 1

        return try fetchDataToBeReturned()
    }
}
