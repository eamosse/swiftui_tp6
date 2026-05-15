//
//  MockData.swift
//  MyRecipes — Séance 1
//

import Foundation

enum MockData {

    static let sample: [Recipe] = [
        Recipe(
            title: "Tarte aux pommes",
            summary: "Le classique inratable du dimanche, avec une compote maison.",
            durationMinutes: 60,
            servings: 6,
            imageName: "applepie",
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "pommes",       quantity: 6,   unit: ""),
                Ingredient(name: "pâte brisée",  quantity: 1,   unit: "rouleau"),
                Ingredient(name: "sucre",        quantity: 80,  unit: "g"),
                Ingredient(name: "cannelle",     quantity: 1,   unit: "c. à c."),
                Ingredient(name: "beurre",       quantity: 30,  unit: "g")
            ],
            steps: [
                "Préchauffer le four à 180°C.",
                "Éplucher et couper les pommes en lamelles.",
                "Étaler la pâte dans le moule.",
                "Disposer les pommes en rosace, saupoudrer de sucre et de cannelle.",
                "Parsemer de noisettes de beurre.",
                "Enfourner 35 minutes, jusqu'à ce que la tarte soit dorée."
            ]
        ),
        Recipe(
            title: "Soupe de potiron au gingembre",
            summary: "Une soupe veloutée et réconfortante.",
            durationMinutes: 40, servings: 4, imageName: "pumpkinsoup",
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "potiron",   quantity: 800, unit: "g"),
                Ingredient(name: "oignon",    quantity: 1,   unit: ""),
                Ingredient(name: "gingembre", quantity: 20,  unit: "g"),
                Ingredient(name: "bouillon",  quantity: 1,   unit: "L")
            ],
            steps: [
                "Faire revenir l'oignon émincé.",
                "Ajouter le gingembre râpé et le potiron.",
                "Couvrir de bouillon, cuire 25 min, puis mixer."
            ]
        ),
        Recipe(
            title: "Risotto aux champignons",
            summary: "Un risotto crémeux et parfumé.",
            durationMinutes: 45, servings: 4, imageName: "risotto",
            difficulty: .medium,
            ingredients: [
                Ingredient(name: "riz arborio",          quantity: 320, unit: "g"),
                Ingredient(name: "champignons de Paris", quantity: 300, unit: "g"),
                Ingredient(name: "échalote",             quantity: 2,   unit: ""),
                Ingredient(name: "vin blanc",            quantity: 10,  unit: "cl"),
                Ingredient(name: "bouillon",             quantity: 1,   unit: "L"),
                Ingredient(name: "parmesan",             quantity: 80,  unit: "g")
            ],
            steps: [
                "Émincer les échalotes et les champignons.",
                "Faire revenir, ajouter le riz, nacrer.",
                "Déglacer au vin blanc, puis bouillon louche par louche.",
                "Incorporer le parmesan hors du feu."
            ]
        ),
        Recipe(
            title: "Salade César revisitée",
            summary: "Avec poulet croustillant et croûtons maison.",
            durationMinutes: 25, servings: 2, imageName: "caesar",
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "blanc de poulet", quantity: 2, unit: ""),
                Ingredient(name: "romaine",         quantity: 1, unit: ""),
                Ingredient(name: "parmesan",        quantity: 40, unit: "g")
            ],
            steps: [
                "Cuire les blancs de poulet.",
                "Préparer la sauce.",
                "Mélanger romaine, poulet, croûtons, parmesan."
            ]
        ),
        Recipe(
            title: "Mille-feuille aux fraises",
            summary: "Pâte feuilletée, crème pâtissière, fraises gariguette.",
            durationMinutes: 90, servings: 6, imageName: "millefeuille",
            difficulty: .hard,
            ingredients: [
                Ingredient(name: "pâte feuilletée", quantity: 2,   unit: "rouleaux"),
                Ingredient(name: "lait",            quantity: 50,  unit: "cl"),
                Ingredient(name: "jaunes d'œufs",   quantity: 4,   unit: ""),
                Ingredient(name: "sucre",           quantity: 100, unit: "g"),
                Ingredient(name: "fraises",         quantity: 500, unit: "g")
            ],
            steps: [
                "Préparer une crème pâtissière.",
                "Cuire la pâte feuilletée entre deux plaques.",
                "Monter en alternant pâte, crème, fraises."
            ]
        )
    ]
}
