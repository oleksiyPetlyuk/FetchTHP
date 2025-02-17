//
//  RecipesNavigationView.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/12/25.
//

import SwiftUI

struct RecipesNavigationView: View {
    private let viewModel: RecipesViewModel

    init(viewModel: RecipesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            RecipesListView(viewModel: viewModel)
                .navigationTitle("Recipes")
        }
    }
}

#Preview {
    RecipesNavigationView(viewModel: RecipesViewModel())
}
