//
//  RecipeCardView.swift
//  MyRecipes — Séance 2, inchangé.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ZStack {
                LinearGradient(
                    colors: [.orange.opacity(0.6), .pink.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(height: 180)

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title).font(.headline).lineLimit(2)
                Text(recipe.summary)
                    .font(.subheadline).foregroundStyle(.secondary).lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(recipe.durationMinutes) min", systemImage: "clock")
                    Label("\(recipe.servings) pers.", systemImage: "person.2")
                    Spacer()
                    Label(recipe.difficulty.rawValue,
                          systemImage: recipe.difficulty.iconName)
                        .foregroundStyle(.orange)
                }
                .font(.caption).foregroundStyle(.secondary).padding(.top, 4)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
    }
}

#Preview {
    RecipeCardView(recipe: MockData.sample[0])
        .padding()
        .background(Color(.systemGroupedBackground))
}
