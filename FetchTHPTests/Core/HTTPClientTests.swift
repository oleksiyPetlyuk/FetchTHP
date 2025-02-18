//
//  HTTPClientTests.swift
//  FetchTHPTests
//
//  Created by Petlyuk, Oleksiy on 2/17/25.
//

import Testing
import Foundation
@testable import FetchTHP

struct HTTPClientTests {
    private let sessionSpy: URLSessionSpy
    private let environment: HTTPClient.Environment
    private let sut: HTTPClient

    private let exampleResource = Resource(path: "recipes.json", method: .POST, query: ["page": "2", "sort": "desc"])

    init() {
        sessionSpy = URLSessionSpy()
        environment = HTTPClient.Environment(scheme: "https", host: "tests.com")
        sut = HTTPClient(session: sessionSpy, environment: environment)
    }

    @Test func shouldCreateURLRequestFromResource() throws {
        let result = sut.request(for: exampleResource)

        let expectedRequest = {
            var components = URLComponents()

            components.scheme = environment.scheme
            components.host = environment.host
            components.path = "/" + exampleResource.path
            components.queryItems = exampleResource.query.map { key, value in URLQueryItem(name: key, value: value) }

            var request = URLRequest(url: components.url!)
            request.httpMethod = exampleResource.method.rawValue

            return request
        }()
        #expect(result == expectedRequest)
    }

    @Test func fetch_shouldThrowInvalidResponseNetworkError_whenErrorStatusCodeReceived() async throws {
        let response = try #require(HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!)
        sessionSpy.dataToBeReturned = { (Data(), response) }

        await #expect(throws: NetworkError.invalidResponse) {
            try await sut.fetch(resource: exampleResource)
        }

        #expect(sessionSpy.dataForRequestCalledCount == 1)
    }

    @Test func fetch_shouldThrowNetworkError_whenThereIsNoInternetConnection() async throws {
        sessionSpy.dataToBeReturned = { throw URLError(.notConnectedToInternet) }

        await #expect(throws: NetworkError.notConnectedToInternet) {
            try await sut.fetch(resource: exampleResource)
        }

        #expect(sessionSpy.dataForRequestCalledCount == 1)
    }

    @Test func fetch_shouldThrowNetworkError_whenRequestWasCancelled() async throws {
        sessionSpy.dataToBeReturned = { throw URLError(.cancelled) }

        await #expect(throws: NetworkError.cancelled) {
            try await sut.fetch(resource: exampleResource)
        }

        #expect(sessionSpy.dataForRequestCalledCount == 1)
    }

    @Test func fetch_shouldReThrowNetworkError() async throws {
        sessionSpy.dataToBeReturned = { throw NetworkError.invalidResponse }

        await #expect(throws: NetworkError.invalidResponse) {
            try await sut.fetch(resource: exampleResource)
        }

        #expect(sessionSpy.dataForRequestCalledCount == 1)
    }

    @Test func fetch_shouldThrowNetworkError_whenUnknownErrorWasCatched() async throws {
        let error = URLError(.badServerResponse)
        sessionSpy.dataToBeReturned = { throw error }

        await #expect(throws: NetworkError.networkError(error)) {
            try await sut.fetch(resource: exampleResource)
        }

        #expect(sessionSpy.dataForRequestCalledCount == 1)
    }

    @Test func fetch_shouldReturnResponseData_whenSuccessStatusCodeReceived() async throws {
        let response = try #require(HTTPURLResponse(
            url: URL(string: "https://test.com")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!)
        let data = "Hello".data(using: .utf8)!
        sessionSpy.dataToBeReturned = { (data, response) }

        await #expect(throws: Never.self) {
            let result = try await sut.fetch(resource: exampleResource)

            #expect(result == data)
        }

        #expect(sessionSpy.dataForRequestCalledCount == 1)
    }
}

final class URLSessionSpy: URLSessionProtocol {
    private(set) var dataForRequestCalledCount = 0

    var dataToBeReturned: () throws -> (Data, URLResponse) = { (Data(), URLResponse()) }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataForRequestCalledCount += 1

        return try dataToBeReturned()
    }
}
