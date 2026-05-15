//
//  RecipeListView.swift
//  MyRecipes — Séance 5
//
//  Liste de recettes + bouton « + » qui ouvre EditRecipeView en sheet (CRÉATION).
//

import SwiftUI

struct RecipeListView: View {

    @Bindable var store: RecipeStore

    /// Présente la sheet d'ajout (séance 5).
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.filtered) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color(.systemGroupedBackground))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            store.toggleFavorite(recipe.id)
                        } label: {
                            Label(recipe.isFavorite ? "Retirer" : "Favori",
                                  systemImage: recipe.isFavorite ? "heart.slash" : "heart")
                        }
                        .tint(.pink)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.delete(recipe.id)
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if recipe.isFavorite {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                                .padding(8)
                                .background(.thinMaterial, in: Circle())
                                .padding(12)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Recettes")
            .searchable(
                text: $store.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Rechercher une recette ou un ingrédient"
            )
            .overlay {
                if store.filtered.isEmpty && !store.query.isEmpty {
                    ContentUnavailableView.search(text: store.query)
                }
            }
            .toolbar {
                // Bouton + ajouté en séance 5
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            // Présente le formulaire de CRÉATION (séance 5)
            .sheet(isPresented: $showAddSheet) {
                EditRecipeView(mode: .create, draft: .emptyDraft) { newRecipe in
                    store.add(newRecipe)
                }
                .presentationDetents([.large])
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(store: store, recipeID: recipe.id)
            }
        }
    }
}

#Preview {
    RecipeListView(store: RecipeStore())
}
