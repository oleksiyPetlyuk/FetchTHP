//
//  HTTPClient.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/15/25.
//

import Foundation

protocol DataFetching {
    func fetch(resource: Resource) async throws -> Data
}

final class HTTPClient: DataFetching {
    private let session: URLSessionProtocol
    private let environment: Environment

    init(session: URLSessionProtocol = URLSession.shared, environment: Environment) {
        self.session = session
        self.environment = environment
    }

    func fetch(resource: Resource) async throws -> Data {
        let request = request(for: resource)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.invalidResponse
            }

            return data
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.notConnectedToInternet
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkError.cancelled
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    func request(for resource: Resource) -> URLRequest {
        var components = URLComponents()

        components.scheme = environment.scheme
        components.host = environment.host
        components.path = "/" + resource.path
        components.queryItems = resource.query.map { key, value in URLQueryItem(name: key, value: value) }

        var request = URLRequest(url: components.url!)
        request.httpMethod = resource.method.rawValue

        return request
    }
}

extension HTTPClient {
    struct Environment {
        let scheme: String
        let host: String
    }
}

enum NetworkError: Error {
    case networkError(Error)
    case invalidResponse
    case cancelled
    case notConnectedToInternet
}
