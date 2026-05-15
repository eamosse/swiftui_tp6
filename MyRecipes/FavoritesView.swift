//
//  FavoritesView.swift
//  MyRecipes — Séance 4, inchangé.
//

import SwiftUI

struct FavoritesView: View {

    @Bindable var store: RecipeStore

    var body: some View {
        NavigationStack {
            Group {
                if store.favorites.isEmpty {
                    ContentUnavailableView(
                        "Aucun favori",
                        systemImage: "heart",
                        description: Text("Glissez vers la droite sur une recette pour l'ajouter ici.")
                    )
                } else {
                    List {
                        ForEach(store.favorites) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16,
                                                      bottom: 8, trailing: 16))
                            .listRowBackground(Color(.systemGroupedBackground))
                            .swipeActions(edge: .leading) {
                                Button {
                                    store.toggleFavorite(recipe.id)
                                } label: {
                                    Label("Retirer", systemImage: "heart.slash")
                                }
                                .tint(.pink)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Favoris")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(store: store, recipeID: recipe.id)
            }
        }
    }
}

#Preview("Avec favoris") {
    let store = RecipeStore()
    store.recipes[0].isFavorite = true
    store.recipes[2].isFavorite = true
    return FavoritesView(store: store)
}
