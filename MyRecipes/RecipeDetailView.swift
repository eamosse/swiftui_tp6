//
//  RecipeDetailView.swift
//  MyRecipes — Séance 5
//
//  Vue détail + bouton « Éditer » qui ouvre EditRecipeView en sheet (ÉDITION).
//

import SwiftUI

struct RecipeDetailView: View {

    @Bindable var store: RecipeStore
    let recipeID: UUID

    @State private var showEditSheet = false

    private var recipe: Recipe {
        store.recipes.first(where: { $0.id == recipeID }) ?? .placeholder
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Image héro
                ZStack {
                    LinearGradient(
                        colors: [.orange, .pink.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .frame(height: 250)
                .clipped()

                // Titre + résumé + métadonnées
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title).font(.largeTitle.bold())
                    Text(recipe.summary).font(.body).foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Label("\(recipe.durationMinutes) min", systemImage: "clock")
                        Label("\(recipe.servings) pers.", systemImage: "person.2")
                        Label(recipe.difficulty.rawValue,
                              systemImage: recipe.difficulty.iconName)
                            .foregroundStyle(.orange)
                    }
                    .font(.subheadline).foregroundStyle(.secondary).padding(.top, 4)
                }
                .padding()

                Divider()

                // Ingrédients
                VStack(alignment: .leading, spacing: 12) {
                    Text("INGRÉDIENTS")
                        .font(.caption.bold()).foregroundStyle(.orange).tracking(1.5)

                    ForEach(recipe.ingredients) { ingredient in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(.orange)
                            Text(ingredient.displayText)
                        }
                    }
                }
                .padding()

                Divider()

                // Préparation
                VStack(alignment: .leading, spacing: 16) {
                    Text("PRÉPARATION")
                        .font(.caption.bold()).foregroundStyle(.orange).tracking(1.5)

                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundStyle(.orange)
                                .frame(width: 28, height: 28)
                                .background(Color.orange.opacity(0.15), in: Circle())

                            Text(step).font(.body)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Bouton favori (séance 4)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleFavorite(recipe.id)
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                }
                .tint(.pink)
            }
            // Bouton éditer AJOUTÉ en séance 5
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "Découvrez \(recipe.title) sur MyRecipes !")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditRecipeView(mode: .edit, draft: recipe) { updated in
                store.update(updated)
            }
            .presentationDetents([.large])
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(store: RecipeStore(),
                         recipeID: MockData.sample[0].id)
    }
}
