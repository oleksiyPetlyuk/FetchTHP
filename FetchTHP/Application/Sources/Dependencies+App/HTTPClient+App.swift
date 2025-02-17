//
//  HTTPClient+App.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/16/25.
//

import Foundation

private struct HTTPClientKey: InjectionKey {
    static var liveValue = HTTPClient(
        session: session,
        environment: HTTPClient.Environment(scheme: "https", host: "d3jbb8n5wk0qxi.cloudfront.net")
    )

    static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil

        return URLSession(configuration: configuration)
    }()
}


extension InjectedValues {
    var httpClient: HTTPClient {
        get { Self[HTTPClientKey.self] }
        set { Self[HTTPClientKey.self] = newValue }
    }
}
