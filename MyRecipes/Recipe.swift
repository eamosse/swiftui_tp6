//
//  Recipe.swift
//  MyRecipes — Séance 1 (+ placeholder séance 4 + isValid séance 5).
//

import Foundation
import SwiftData

// MARK: - Difficulty

enum Difficulty: String, CaseIterable, Identifiable, Codable {
    case easy   = "Facile"
    case medium = "Moyen"
    case hard   = "Difficile"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .easy:   return "leaf"
        case .medium: return "flame"
        case .hard:   return "bolt"
        }
    }
}

// MARK: - Ingredient

@Model
final class Ingredient {
    var id: UUID = UUID()
    var name: String
    var quantity: Double
    var unit: String
    
    init(name: String, quantity: Double, unit: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }

    var displayText: String {
        let formattedQty = quantity.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(quantity))
            : String(format: "%.1f", quantity)
        if unit.isEmpty {
            return "\(formattedQty) \(name)"
        }
        return "\(formattedQty) \(unit) de \(name)"
    }
}

// MARK: - Recipe

@Model
final class Recipe {
    var id: UUID = UUID()
    var title: String
    var summary: String
    var durationMinutes: Int
    var servings: Int
    var imageName: String
    var difficulty: Difficulty
    @Relationship(deleteRule : .cascade)
    var ingredients: [Ingredient]
    var steps: [String]
    var isFavorite: Bool = false
    
    init(title: String, summary: String, durationMinutes: Int, servings: Int, imageName: String, difficulty: Difficulty, ingredients: [Ingredient], steps: [String]) {
        self.title = title
        self.summary = summary
        self.durationMinutes = durationMinutes
        self.servings = servings
        self.imageName = imageName
        self.difficulty = difficulty
        self.ingredients = ingredients
        self.steps = steps
    }

    var quickInfo: String {
        "\(durationMinutes) min · \(servings) pers."
    }

    /// Validation utilisée par le formulaire de la séance 5.
    var isValid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3
            && servings > 0
            && durationMinutes > 0
            && !ingredients.isEmpty
    }
}

// MARK: - Placeholder

extension Recipe {
    static let placeholder = Recipe(
        title: "Recette", summary: "",
        durationMinutes: 0, servings: 0,
        imageName: "", difficulty: .easy,
        ingredients: [], steps: []
    )

    /// Brouillon vide utilisé en CRÉATION.
    static let emptyDraft = Recipe(
        title: "", summary: "",
        durationMinutes: 30, servings: 4,
        imageName: "", difficulty: .easy,
        ingredients: [], steps: []
    )
}
