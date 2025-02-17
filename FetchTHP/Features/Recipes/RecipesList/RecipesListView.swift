//
//  RecipesListView.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/12/25.
//

import SwiftUI

struct RecipesListView: View {
    @ObservedObject var viewModel: RecipesViewModel

    var body: some View {
        ZStack {
            render(viewModel.props)
        }
        .task {
            await viewModel.fetch()
        }
    }

    var emptyRecipesView: some View {
        VStack {
            Text("No recipes found")
                .font(.title)
                .foregroundStyle(.secondary)

            retryButton
        }
    }

    var retryButton: some View {
        Button("Retry") {
            Task { await viewModel.fetch() }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.primary)
    }

    func errorView(_ error: Error) -> some View {
        VStack {
            Text(error is OfflineError ? "No internet connection" : "Something went wrong")
                .font(.title)
                .foregroundStyle(.secondary)

            retryButton
        }
    }

    @ViewBuilder func render(_ props: RecipesViewModel.Props) -> some View {
        switch viewModel.props {
        case .initial:
            EmptyView()
        case .loading:
            ProgressView()
        case .loaded(let selectedSortType, let recipes):
            if recipes.isEmpty {
                emptyRecipesView
            } else {
                List {
                    ForEach(recipes, id: \.id) { recipe in
                        RecipeRowView(recipe: recipe)
                    }
                }
                .refreshable {
                    await viewModel.fetch(setLoading: false)
                }
                .listStyle(.plain)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Sort Recipes", systemImage: "arrow.up.arrow.down") {
                            ForEach(DiscoverRecipesSortBy.allCases, id: \.self) { sortBy in
                                Button(action: {
                                    Task { await viewModel.sortBy(sortBy) }
                                }) {
                                    HStack {
                                        Text(sortBy.name)

                                        if selectedSortType == sortBy {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        case .error(let error):
            errorView(error)
        }
    }
}

extension DiscoverRecipesSortBy {
    var name: String {
        switch self {
        case .cuisine:
            "By cuisine"
        case .name:
            "By name"
        }
    }
}

struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.title)
                    .lineLimit(2)

                Text(recipe.cuisine)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.leading)

            Spacer()

            RecipePhotoView(photoURL: recipe.photoURL)
                .fixedSize()
        }
    }
}

#Preview {
    RecipesListView(viewModel: RecipesViewModel())
}
