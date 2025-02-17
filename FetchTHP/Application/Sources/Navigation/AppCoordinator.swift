//
//  AppCoordinator.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/12/25.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var tab: Tab = .recipes

    private lazy var recipesViewModel = RecipesViewModel()

    func makeRecipesView() -> some View {
        RecipesNavigationView(viewModel: recipesViewModel)
            .tabItem { tabBarItem(text: "Recipes", image: "fork.knife") }
    }
}

extension AppCoordinator {
    enum Tab {
        case recipes
    }
}

private extension AppCoordinator {
    func tabBarItem(text: String, image: String) -> some View {
        VStack {
            Image(systemName: image)
                .imageScale(.large)

            Text(text)
        }
    }
}
