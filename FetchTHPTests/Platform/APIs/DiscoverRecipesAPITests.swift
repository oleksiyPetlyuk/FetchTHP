//
//  DiscoverRecipesAPITests.swift
//  FetchTHPTests
//
//  Created by Petlyuk, Oleksiy on 2/17/25.
//

import Foundation
import Testing
@testable import FetchTHP

struct DiscoverRecipesAPITests {
    private let httpClientSpy: HTTPClientSpy
    private let sut: LiveDiscoverRecipesAPI

    init() {
        httpClientSpy = HTTPClientSpy()
        sut = LiveDiscoverRecipesAPI(client: httpClientSpy)
    }

    @Test func fetch_shouldReturnRecipes_whenDataIsCorrect() async throws {
        await #expect(throws: Never.self) {
            let expectedResponse = RecipeResponse(recipes: [Recipe.sample, Recipe.sample, Recipe.sample])
            httpClientSpy.fetchDataToBeReturned = { try JSONEncoder().encode(expectedResponse) }

            let result = try await sut.fetch()

            #expect(result == expectedResponse.recipes)
            #expect(httpClientSpy.fetchCalledCount == 1)
        }
    }

    @Test func fetch_shouldThrowDecodingError_whenDataIsMalformed() async throws {
        await #expect(throws: DecodingError.self) {
            try await sut.fetch()
        }

        #expect(httpClientSpy.fetchCalledCount == 1)
    }

    @Test func fetch_shouldThrowOfflineError_whenThereIsNoInternetConnection() async throws {
        httpClientSpy.fetchDataToBeReturned = { throw NetworkError.notConnectedToInternet }

        await #expect(throws: OfflineError.self) {
            try await sut.fetch()
        }

        #expect(httpClientSpy.fetchCalledCount == 1)
    }

    @Test func fetch_shouldReThrowNetworkError() async throws {
        httpClientSpy.fetchDataToBeReturned = { throw NetworkError.invalidResponse }

        await #expect(throws: NetworkError.invalidResponse) {
            try await sut.fetch()
        }

        #expect(httpClientSpy.fetchCalledCount == 1)
    }
}

final class HTTPClientSpy: DataFetching {
    private(set) var fetchCalledCount = 0

    var fetchDataToBeReturned: () throws -> Data = { Data() }

    func fetch(resource: FetchTHP.Resource) async throws -> Data {
        fetchCalledCount += 1

        return try fetchDataToBeReturned()
    }
}
