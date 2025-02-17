//
//  ContentView.swift
//  FetchTHP
//
//  Created by Petlyuk, Oleksiy on 2/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        TabView {
            coordinator.makeRecipesView()
                .tag(AppCoordinator.Tab.recipes)
        }
    }
}

#Preview {
    ContentView()
}
