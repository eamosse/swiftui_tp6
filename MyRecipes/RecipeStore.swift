//
//  RecipeStore.swift
//  MyRecipes — Séance 3 + ajout `update` en séance 5.
//

import Foundation
import Observation
import SwiftData

@Observable
final class RecipeStore {


    var recipes: [Recipe]
    var query: String = ""

    init(recipes: [Recipe] = MockData.sample) {
        self.recipes = recipes
    }

    // MARK: - Lecture filtrée

    var filtered: [Recipe] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return recipes }
        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(trimmed)
            ||
            recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    var favorites: [Recipe] {
        recipes.filter(\.isFavorite)
    }

    // MARK: - Mutations

    func toggleFavorite(_ id: UUID) {
        guard let index = recipes.firstIndex(where: { $0.id == id }) else { return }
        recipes[index].isFavorite.toggle()
    }

    func delete(_ id: UUID) {
        recipes.removeAll { $0.id == id }
    }

    func add(_ recipe: Recipe) {
        recipes.insert(recipe, at: 0)
    }

    /// Met à jour une recette existante (séance 5).
    /// Préserve l'ID — pas de duplication.
    func update(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index] = recipe
    }
}
