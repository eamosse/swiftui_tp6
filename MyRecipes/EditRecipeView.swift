//
//  EditRecipeView.swift
//  MyRecipes — Séance 5
//
//  Formulaire d'ajout / édition d'une recette.
//
//  Pattern « brouillon » : on travaille sur une copie modifiable du Recipe,
//  jamais sur la recette originale du store. Le parent décide à la fin
//  d'appeler `add` (création) ou `update` (édition).
//

import SwiftUI

struct EditRecipeView: View {

    /// Le mode change le titre et le comportement de sauvegarde — c'est tout.
    enum Mode {
        case create
        case edit
    }

    let mode: Mode

    /// Le brouillon modifiable. Une COPIE de la recette, jamais la recette
    /// originale du store directement.
    @State var draft: Recipe

    /// Callback déclenché quand l'utilisateur valide.
    let onSave: (Recipe) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Informations
                Section {
                    TextField("Titre de la recette", text: $draft.title)

                    TextField("Résumé", text: $draft.summary, axis: .vertical)
                        .lineLimit(2...5)

                    // Feedback inline : titre trop court
                    if !draft.title.isEmpty && draft.title.trimmingCharacters(in: .whitespaces).count < 3 {
                        Text("Le titre doit faire au moins 3 caractères.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Informations")
                }

                // MARK: Quantités
                Section("Quantités") {
                    Stepper("Durée : \(draft.durationMinutes) min",
                            value: $draft.durationMinutes,
                            in: 5...300, step: 5)

                    Stepper("Portions : \(draft.servings)",
                            value: $draft.servings,
                            in: 1...20)

                    Picker("Difficulté", selection: $draft.difficulty) {
                        ForEach(Difficulty.allCases) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: Ingrédients
                Section {
                    ForEach($draft.ingredients) { $ingredient in
                        HStack(spacing: 8) {
                            TextField("Nom", text: $ingredient.name)

                            TextField("Qté", value: $ingredient.quantity,
                                      formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                                .multilineTextAlignment(.trailing)

                            TextField("Unité", text: $ingredient.unit)
                                .frame(width: 60)
                        }
                    }
                    .onDelete { indexSet in
                        draft.ingredients.remove(atOffsets: indexSet)
                    }

                    Button {
                        draft.ingredients.append(
                            Ingredient(name: "", quantity: 1, unit: "g")
                        )
                    } label: {
                        Label("Ajouter un ingrédient", systemImage: "plus.circle.fill")
                    }
                } header: {
                    HStack {
                        Text("Ingrédients")
                        if draft.ingredients.isEmpty {
                            Text("(au moins un requis)")
                                .foregroundStyle(.red)
                                .textCase(nil)
                        }
                    }
                }

                // MARK: Étapes
                Section("Préparation") {
                    ForEach($draft.steps.indices, id: \.self) { index in
                        TextField("Étape \(index + 1)",
                                  text: $draft.steps[index],
                                  axis: .vertical)
                            .lineLimit(1...3)
                    }
                    .onDelete { indexSet in
                        draft.steps.remove(atOffsets: indexSet)
                    }

                    Button {
                        draft.steps.append("")
                    } label: {
                        Label("Ajouter une étape", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle(mode == .create ? "Nouvelle recette" : "Modifier la recette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        onSave(draft)
                        dismiss()
                    }
                    .bold()
                    .disabled(!draft.isValid)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Création") {
    EditRecipeView(mode: .create, draft: Recipe.emptyDraft) { _ in }
}

#Preview("Édition") {
    EditRecipeView(mode: .edit, draft: MockData.sample[0]) { _ in }
}
