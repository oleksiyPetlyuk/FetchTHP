//
//  DiscoverRecipesUseCase+App.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/16/25.
//

import Foundation

private struct DiscoverRecipesUseCaseKey: InjectionKey {
    static var liveValue: DiscoverRecipesUseCase = {
        @Injected(\.httpClient) var httpClient

        return LiveDiscoverRecipesUseCase(api: LiveDiscoverRecipesAPI(client: httpClient))
    }()

    static var previewValue: DiscoverRecipesUseCase? = MockDiscoverRecipesUseCase()
}


extension InjectedValues {
    var discoverRecipesUseCase: DiscoverRecipesUseCase {
        get { Self[DiscoverRecipesUseCaseKey.self] }
        set { Self[DiscoverRecipesUseCaseKey.self] = newValue }
    }
}
