//
//  RecipesViewModel.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/12/25.
//

import Foundation

@MainActor
final class RecipesViewModel: ObservableObject {
    @Published var props: Props = .initial

    @Injected(\.discoverRecipesUseCase) private var useCase

    func fetch(setLoading: Bool = true) async {
        if props.isLoading { return }

        do {
            let sortRecipesBy = props.sortRecipesBy ?? .name

            if setLoading {
                props = .loading
            }

            let recipes = try await useCase.fetch(sortBy: sortRecipesBy)
            props = .loaded(sortRecipesBy, recipes)
        } catch {
            props = .error(error)
        }
    }

    func sortBy(_ sortBy: DiscoverRecipesSortBy) async {
        guard case .loaded(_, let recipes) = props else { return }

        props = .loaded(sortBy, recipes)

        await fetch()
    }
}

extension RecipesViewModel {
    enum Props {
        case initial
        case loading
        case loaded(DiscoverRecipesSortBy, [Recipe])
        case error(Error)

        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }

        var sortRecipesBy: DiscoverRecipesSortBy? {
            switch self {
            case .loaded(let sortBy, _):
                return sortBy
            default:
                return nil
            }
        }
    }
}
