//
//  RootView.swift
//  MyRecipes — Séance 4, inchangé.
//

import SwiftUI

struct RootView: View {

    @State private var store = RecipeStore()

    var body: some View {
        TabView {
            RecipeListView(store: store)
                .tabItem { Label("Recettes", systemImage: "book") }

            FavoritesView(store: store)
                .tabItem { Label("Favoris", systemImage: "heart") }
                .badge(store.favorites.count)

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
        .tint(.orange)
    }
}

#Preview {
    RootView()
}
