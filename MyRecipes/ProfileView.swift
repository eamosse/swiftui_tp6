//
//  ProfileView.swift
//  MyRecipes — Séance 4, inchangé.
//

import SwiftUI

struct ProfileView: View {

    @State private var notificationsEnabled: Bool = false
    @State private var automaticTheme: Bool = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Nom", value: "Étudiant·e")
                    LabeledContent("Recettes créées", value: "0")
                    LabeledContent("Favoris", value: "—")
                }
                Section("Préférences") {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                    Toggle("Thème automatique", isOn: $automaticTheme)
                }
                Section {
                    Button("Réinitialiser les données", role: .destructive) { }
                }
            }
            .navigationTitle("Profil")
        }
    }
}

#Preview {
    ProfileView()
}
