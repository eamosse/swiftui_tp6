# Séance 6 — Exercices : guidé puis autonome

À la fin de cette séance, **MyRecipes** devient **persistant** : les recettes survivent au redémarrage de l'app. On remplace `RecipeStore` (en mémoire) par SwiftData (`@Model` + `@Query`).

```
Séance 5 : Création / édition en mémoire → Séance 6 : Persistance sur disque
```

> Comme la séance 5, ce TP est en **deux temps** : une **partie guidée** (~50 % du TP) qui couvre les vrais sauts conceptuels (migration vers `@Model`, découverte de `@Query`), puis une **partie autonome** (~50 %) où vous appliquez ce que vous avez vu pour finaliser le CRUD et les favoris.

---

# 🟢 Exercice 6.1 — Migration vers @Model (PARTIE GUIDÉE)

> Objectif : convertir `Recipe` et `Ingredient` en entités SwiftData, et brancher le `ModelContainer` sur l'App.

## Étape 1.1 — Comprendre ce qui va changer

`Recipe` était une `struct`. Pour `@Model`, on doit le transformer en `final class`. Conséquences en cascade :

- Tous les `let recipe = ...` qui font des copies → continuent de marcher, mais la sémantique change (référence partagée).
- Le store `RecipeStore` devient inutile : SwiftData prend sa place.
- Les `@Bindable` sur le `Recipe` deviennent encore plus pertinents (puisque c'est une class).
- Les Previews doivent fournir un `ModelContainer` en mémoire.

## Étape 1.2 — Convertir Ingredient en @Model

Ouvrez `Recipe.swift`. Modifiez la struct `Ingredient` :

```swift
import Foundation
import SwiftData

// MARK: - Ingredient

@Model
final class Ingredient {
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
```

**À comprendre** :
- `import SwiftData` en haut du fichier.
- `struct → final class`.
- L'`id` automatique est géré par SwiftData : on ne déclare PLUS `var id: UUID`.
- L'`init` doit être complet (les classes en Swift ne génèrent pas d'init membre comme les struct).

## Étape 1.3 — Convertir Recipe en @Model

Toujours dans `Recipe.swift`, après l'enum `Difficulty`, remplacez la struct `Recipe` par :

```swift
// MARK: - Recipe

@Model
final class Recipe {
    var title: String
    var summary: String
    var durationMinutes: Int
    var servings: Int
    var imageName: String
    var isFavorite: Bool

    /// On stocke le rawValue de la difficulté ; SwiftData ne supporte
    /// pas tous les enums Codable de manière fluide.
    private var difficultyRaw: String

    /// Accesseur lisible pour conserver l'API précédente.
    var difficulty: Difficulty {
        get { Difficulty(rawValue: difficultyRaw) ?? .easy }
        set { difficultyRaw = newValue.rawValue }
    }

    /// Relation : un Recipe a plusieurs Ingredient.
    /// deleteRule: .cascade → supprimer la recette supprime ses ingrédients.
    @Relationship(deleteRule: .cascade)
    var ingredients: [Ingredient]

    /// Étapes stockées comme array de String (SwiftData supporte).
    var steps: [String]

    init(title: String,
         summary: String = "",
         durationMinutes: Int = 30,
         servings: Int = 4,
         imageName: String = "",
         difficulty: Difficulty = .easy,
         ingredients: [Ingredient] = [],
         steps: [String] = []) {
        self.title = title
        self.summary = summary
        self.durationMinutes = durationMinutes
        self.servings = servings
        self.imageName = imageName
        self.difficultyRaw = difficulty.rawValue
        self.isFavorite = false
        self.ingredients = ingredients
        self.steps = steps
    }

    var quickInfo: String {
        "\(durationMinutes) min · \(servings) pers."
    }

    var isValid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 3
            && servings > 0
            && durationMinutes > 0
            && !ingredients.isEmpty
    }
}
```

**À comprendre** :
- L'enum `Difficulty` est stockée en `String` via `difficultyRaw`. C'est une convention SwiftData courante.
- `@Relationship(deleteRule: .cascade)` : si on supprime un Recipe, ses Ingredient suivent.
- Pas de conformance manuelle à `Identifiable` ou `Hashable` — SwiftData s'en charge.

Supprimez aussi les extensions `placeholder` et `emptyDraft` à la fin du fichier (on les recréera à la fin de l'exercice si besoin).

## Étape 1.4 — Activer le ModelContainer sur l'App

Ouvrez `MyRecipesApp.swift`. Modifiez-le :

```swift
import SwiftUI
import SwiftData

@main
struct MyRecipesApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Recipe.self, Ingredient.self])
    }
}
```

**À comprendre** :
- `.modelContainer(for: [...])` crée la base SQLite au premier lancement, la réutilise ensuite.
- Lister TOUS les @Model utilisés dans cet array.
- Le fichier de base se crée automatiquement dans `Library/Application Support/` du sandbox de l'app.

## Étape 1.5 — Adapter MockData pour insérer dans le contexte

Le `MockData.sample` retournait jusqu'ici une `[Recipe]` directement. Maintenant, on ne peut plus initialiser les recettes à l'avance — il faut les créer ET les insérer dans le contexte.

Remplacez le contenu de `MockData.swift` par :

```swift
import Foundation
import SwiftData

enum MockData {

    /// Insère un jeu de recettes d'exemple dans le contexte fourni.
    /// À appeler une seule fois, au premier démarrage si la base est vide.
    static func seedIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<Recipe>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let tarte = Recipe(
            title: "Tarte aux pommes",
            summary: "Le classique inratable du dimanche.",
            durationMinutes: 60, servings: 6,
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "pommes", quantity: 6, unit: ""),
                Ingredient(name: "pâte brisée", quantity: 1, unit: "rouleau"),
                Ingredient(name: "sucre", quantity: 80, unit: "g")
            ],
            steps: [
                "Préchauffer le four à 180°C.",
                "Éplucher et couper les pommes.",
                "Enfourner 35 minutes."
            ]
        )

        let soupe = Recipe(
            title: "Soupe de potiron",
            summary: "Veloutée et réconfortante.",
            durationMinutes: 40, servings: 4,
            difficulty: .easy,
            ingredients: [
                Ingredient(name: "potiron", quantity: 800, unit: "g"),
                Ingredient(name: "oignon", quantity: 1, unit: ""),
                Ingredient(name: "bouillon", quantity: 1, unit: "L")
            ],
            steps: [
                "Faire revenir l'oignon.",
                "Ajouter potiron et bouillon, cuire 25 min, mixer."
            ]
        )

        let risotto = Recipe(
            title: "Risotto aux champignons",
            summary: "Crémeux et parfumé.",
            durationMinutes: 45, servings: 4,
            difficulty: .medium,
            ingredients: [
                Ingredient(name: "riz arborio", quantity: 320, unit: "g"),
                Ingredient(name: "champignons", quantity: 300, unit: "g"),
                Ingredient(name: "parmesan", quantity: 80, unit: "g")
            ],
            steps: [
                "Faire revenir les champignons.",
                "Nacrer le riz, ajouter le bouillon louche par louche."
            ]
        )

        for recipe in [tarte, soupe, risotto] {
            context.insert(recipe)
        }
        try? context.save()
    }
}
```

**À comprendre** :
- On vérifie d'abord si la base est vide via `fetchCount`. Sinon on insérerait des doublons à chaque lancement.
- `context.insert(recipe)` ajoute. `context.save()` force la sauvegarde immédiate (sinon SwiftData le fait automatiquement quelques secondes plus tard).

Puis branchez le seed dans `MyRecipesApp.swift` :

```swift
@main
struct MyRecipesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Recipe.self, Ingredient.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Impossible de créer le container : \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .onAppear {
                    MockData.seedIfNeeded(in: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
```

## Étape 1.6 — Tester la compilation

`Cmd + B`. Vous allez voir **plein** d'erreurs dans `RecipeListView`, `RecipeDetailView`, `RecipeStore`, `FavoritesView`, `EditRecipeView`. C'est normal — on les corrige en 6.2.

Pour l'instant, vérifiez juste que `Recipe.swift`, `Ingredient.swift`, `MockData.swift`, `MyRecipesApp.swift` compilent SANS erreur.

## ✅ Critères de validation 6.1

- [ ] `Ingredient` et `Recipe` sont des `final class` avec `@Model`.
- [ ] `import SwiftData` présent dans `Recipe.swift`.
- [ ] `@Relationship(deleteRule: .cascade)` sur `ingredients`.
- [ ] `MyRecipesApp.swift` déclare un `ModelContainer` et l'attache au `WindowGroup`.
- [ ] `MockData.seedIfNeeded(in:)` insère 3-5 recettes la première fois.
- [ ] Les 4 fichiers du dessus compilent SANS erreur (le reste cassera, c'est attendu).

---

# 🟢 Exercice 6.2 — Liste avec @Query (PARTIE GUIDÉE)

> ⏱ **30 minutes** • Objectif : remplacer `RecipeStore` par `@Query` dans la vue Liste.

## Étape 2.1 — Réécrire RecipeListView

Ouvrez `RecipeListView.swift`. Supprimez la référence au store et remplacez par :

```swift
import SwiftUI
import SwiftData

struct RecipeListView: View {

    /// La VUE demande directement les recettes au store SwiftData.
    /// SwiftData observe la base : la vue se redessine aux changements.
    @Query(sort: [
        SortDescriptor(\Recipe.isFavorite, order: .reverse),
        SortDescriptor(\Recipe.title)
    ])
    private var recipes: [Recipe]

    @Environment(\.modelContext) private var context

    /// Recherche locale (la chaîne est dans @State, le filtre côté Swift).
    @State private var searchText: String = ""

    @State private var showAddSheet = false

    /// Filtrage simple côté Swift sur le résultat de @Query.
    private var filtered: [Recipe] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return recipes }
        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(trimmed)
            ||
            recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(trimmed) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { recipe in
                    NavigationLink(value: recipe) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color(.systemGroupedBackground))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            recipe.isFavorite.toggle()
                            try? context.save()
                        } label: {
                            Label(recipe.isFavorite ? "Retirer" : "Favori",
                                  systemImage: recipe.isFavorite ? "heart.slash" : "heart")
                        }
                        .tint(.pink)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            context.delete(recipe)
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
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Rechercher")
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "Aucune recette" : "Aucun résultat",
                        systemImage: "book",
                        description: Text(searchText.isEmpty
                                          ? "Tappez + pour ajouter votre première recette."
                                          : "Essayez un autre mot-clé.")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                // À implémenter en 6.3 — laissez ce sheet vide pour l'instant
                Text("Sheet à implémenter en 6.3").padding()
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
```

**À comprendre** :
- `@Query` remplace complètement le `store`. Pas de `RecipeStore` partagé, chaque vue qui veut des recettes les demande directement.
- `@Environment(\.modelContext)` pour récupérer le contexte → permet `insert`, `delete`, `save`.
- `recipe.isFavorite.toggle()` modifie DIRECTEMENT la propriété. SwiftData détecte et sauvegarde.
- En Preview : `.modelContainer(for: Recipe.self, inMemory: true)` fournit un container temporaire.

## Étape 2.2 — Adapter RecipeDetailView

`RecipeDetailView` recevait jusqu'ici `store` et `recipeID`. Maintenant, on lui passe directement la `Recipe` (qui est une class @Model, donc une référence vivante).

```swift
import SwiftUI
import SwiftData

struct RecipeDetailView: View {

    /// On reçoit directement la recette — c'est une class @Model,
    /// donc toute modification est observée et sauvegardée.
    @Bindable var recipe: Recipe

    @Environment(\.modelContext) private var context
    @State private var showEditSheet = false

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

                VStack(alignment: .leading, spacing: 12) {
                    Text("INGRÉDIENTS").font(.caption.bold()).foregroundStyle(.orange)
                    ForEach(recipe.ingredients) { ingredient in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6)).foregroundStyle(.orange)
                            Text(ingredient.displayText)
                        }
                    }
                }
                .padding()

                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("PRÉPARATION").font(.caption.bold()).foregroundStyle(.orange)
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline).foregroundStyle(.orange)
                                .frame(width: 28, height: 28)
                                .background(Color.orange.opacity(0.15), in: Circle())
                            Text(step).font(.body)
                        }
                    }
                }
                .padding().padding(.bottom, 24)
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    recipe.isFavorite.toggle()
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                }
                .tint(.pink)
            }
            // Bouton Éditer — sheet à compléter en 6.3
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            Text("Sheet d'édition à implémenter en 6.3").padding()
        }
    }
}
```

**À comprendre** :
- Plus de `recipeID` + lookup dans un store — la recette EST une référence vivante.
- `@Bindable var recipe` permet d'utiliser `$recipe.title` si on veut un TextField dessus (utile pour l'édition inline).
- `recipe.isFavorite.toggle()` est DÉTECTÉ automatiquement par SwiftData.

## Étape 2.3 — Adapter FavoritesView

Remplacez `FavoritesView.swift` par :

```swift
import SwiftUI
import SwiftData

struct FavoritesView: View {

    /// Filtre côté base de données via #Predicate.
    @Query(filter: #Predicate<Recipe> { $0.isFavorite },
           sort: \Recipe.title)
    private var favorites: [Recipe]

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "Aucun favori",
                        systemImage: "heart",
                        description: Text("Glissez vers la droite sur une recette pour l'ajouter ici.")
                    )
                } else {
                    List {
                        ForEach(favorites) { recipe in
                            NavigationLink(value: recipe) {
                                RecipeCardView(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16,
                                                      bottom: 8, trailing: 16))
                            .listRowBackground(Color(.systemGroupedBackground))
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Favoris")
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
```

**À comprendre** :
- `#Predicate<Recipe> { $0.isFavorite }` est un filtre TYPE-SAFE compilé en SQL. Plus rapide que `filter()` Swift.
- Pas besoin du store : `@Query` lit directement la base.

## Étape 2.4 — Mettre à jour RootView

Le store n'a plus de raison d'exister. Modifiez `RootView.swift` :

```swift
import SwiftUI
import SwiftData

struct RootView: View {

    /// On lit le compte des favoris pour le badge.
    @Query(filter: #Predicate<Recipe> { $0.isFavorite })
    private var favorites: [Recipe]

    var body: some View {
        TabView {
            RecipeListView()
                .tabItem { Label("Recettes", systemImage: "book") }

            FavoritesView()
                .tabItem { Label("Favoris", systemImage: "heart") }
                .badge(favorites.count)

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
        .tint(.orange)
    }
}

#Preview {
    RootView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
```

## Étape 2.5 — Archiver RecipeStore

Vous pouvez **supprimer** `RecipeStore.swift` du projet (clic droit → Delete → **Move to Trash** ou **Remove Reference**). SwiftData remplace tout ce qu'il faisait.

## Étape 2.6 — Tester

Lancez (`Cmd + R`). Vous devriez voir vos 3 recettes mockées. Faites :

1. Marquer Tarte en favori → onglet Favoris : la tarte apparaît, badge = 1.
2. Glisser une recette vers la gauche → supprimer.
3. Killer l'app (`Cmd + Shift + H` dans le simulateur) puis relancer.
4. **Les changements sont préservés** — c'est la magie de SwiftData.

## ✅ Critères de validation 6.2

- [ ] `RecipeListView`, `FavoritesView` et `RootView` utilisent `@Query`.
- [ ] `RecipeDetailView` reçoit directement `@Bindable var recipe: Recipe`.
- [ ] Tap sur le cœur dans la barre → bascule favori sans appeler de méthode du store.
- [ ] Swipe → supprimer fonctionne via `context.delete(recipe)`.
- [ ] Les changements survivent à un kill + relance de l'app.
- [ ] `RecipeStore.swift` n'est plus utilisé (peut être supprimé).

---

# 🟠 Exercice 6.3 — CRUD complet (PARTIE AUTONOME)

> ⏱ **30 minutes** • Objectif : reconnecter `EditRecipeView` au formulaire de création / édition avec SwiftData.

## Spécification

Le formulaire `EditRecipeView` doit fonctionner comme avant (séance 5), mais en utilisant SwiftData :

- **Création** (depuis le bouton + de la liste) : créer une nouvelle `Recipe`, l'insérer dans le contexte, puis fermer la sheet.
- **Édition** (depuis le crayon de la vue détail) : modifier la `Recipe` existante en place. Comme c'est une class @Model, les modifications sont auto-sauvegardées.

## Pistes

### 1. Adapter EditRecipeView au mode @Model

Le pattern « brouillon copié » de la séance 5 ne marche plus directement — on ne peut pas copier un `@Model` proprement. Deux approches :

**Approche A — Création seulement :** `EditRecipeView` est utilisée uniquement pour CRÉER. Quand on édite, on modifie directement la `Recipe` du store via `@Bindable`. Donc :
- Bouton + → ouvrir `EditRecipeView(draft: Recipe(title: ""))` → à l'enregistrement, `context.insert(draft)`.
- Bouton crayon → ouvrir une vue d'édition séparée qui prend `@Bindable var recipe` et modifie en direct.

**Approche B — Brouillon temporaire :** `EditRecipeView` continue de prendre un brouillon, mais on s'arrange pour ne PAS l'insérer tant que l'utilisateur n'a pas validé.

Choisissez **l'approche A** — c'est l'idiome SwiftData le plus propre.

### 2. Structure d'EditRecipeView pour la création

```swift
struct EditRecipeView: View {
    @Bindable var draft: Recipe   // crée un Recipe NON inséré
    let onSave: (Recipe) -> Void
    @Environment(\.dismiss) var dismiss

    // … le Form existant fonctionne, $draft.title etc.
}
```

Dans `RecipeListView.swift`, le `.sheet` devient :

```swift
.sheet(isPresented: $showAddSheet) {
    EditRecipeView(draft: Recipe(title: "")) { newRecipe in
        // À vous : insérer newRecipe dans le contexte
    }
    .presentationDetents([.large])
}
```

### 3. Édition : modifier la Recipe en place

Au lieu d'avoir une `EditRecipeView` en mode édition, vous pouvez créer une **nouvelle vue** plus simple `RecipeEditInlineView` qui prend `@Bindable var recipe: Recipe` et expose les mêmes champs. Pas besoin de brouillon, pas besoin de save : SwiftData détecte tout.

```swift
struct RecipeEditInlineView: View {
    @Bindable var recipe: Recipe
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // À vous : reprendre les sections de EditRecipeView mais avec $recipe.xxx
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                }
            }
        }
    }
}
```

### 4. Brancher dans RecipeDetailView

```swift
.sheet(isPresented: $showEditSheet) {
    RecipeEditInlineView(recipe: recipe)
        .presentationDetents([.large])
}
```

## ✅ Critères de validation 6.3

- [ ] Le bouton + ouvre une sheet de création.
- [ ] Enregistrer insère la nouvelle recette via `context.insert(...)`.
- [ ] La nouvelle recette apparaît immédiatement dans la liste (grâce à @Query).
- [ ] Le bouton crayon ouvre la sheet d'édition.
- [ ] Toute modification dans l'édition est immédiatement visible dans le détail (sans bouton « Enregistrer »).
- [ ] Kill l'app + relance → toutes les modifications persistent.

## Pour aller plus loin

- Ajouter un bouton **Supprimer** rouge en bas de `RecipeEditInlineView`.
- Ajouter une `.alert` de confirmation avant la suppression.
- Validation côté création : désactiver Enregistrer si `!draft.isValid`.

---

# 🟠 Exercice 6.4 — Favoris persistants (PARTIE AUTONOME)

> ⏱ **15 minutes** • Objectif : vérifier que les favoris survivent au redémarrage, et ajouter quelques touches finales.

## Constat

En passant de `RecipeStore` à SwiftData, **les favoris sont déjà persistants**. SwiftData sauvegarde `isFavorite` automatiquement. Bravo, l'exercice est presque gratuit !

## À vérifier

1. Lancer l'app, marquer 3 recettes en favori.
2. **Cmd + Shift + H** dans le simulateur (Home).
3. **Cmd + Shift + H** une 2ᵉ fois pour ouvrir le sélecteur d'apps.
4. Glisser MyRecipes vers le haut pour la tuer.
5. Cliquer à nouveau sur l'icône MyRecipes.
6. → Les 3 favoris sont toujours là, badge = 3 sur l'onglet Favoris. ✅

## À écrire vous-mêmes

### A. Compteur dynamique dans le profil

Dans `ProfileView`, remplacer la ligne `LabeledContent("Recettes créées", value: "0")` par un vrai compteur lu via `@Query`. **Indice** :

```swift
@Query private var allRecipes: [Recipe]

// puis dans le body :
LabeledContent("Recettes créées", value: "\(allRecipes.count)")
```

### B. Bouton « Réinitialiser les données »

Dans `ProfileView`, le bouton rouge « Réinitialiser les données » doit maintenant SUPPRIMER toutes les recettes via le contexte.

```swift
@Environment(\.modelContext) private var context
@Query private var allRecipes: [Recipe]

// dans l'action du bouton :
for recipe in allRecipes {
    context.delete(recipe)
}
```

Bonus : encadrer dans une `.alert` de confirmation avant la suppression.

### C. Re-seed après réinitialisation

Si l'utilisateur a tout supprimé, il pourrait vouloir réinitialiser AVEC les recettes mockées. Ajoutez un bouton « Restaurer les recettes d'exemple » qui appelle `MockData.seedIfNeeded(in: context)`.

## ✅ Critères de validation 6.4

- [ ] Les favoris survivent au kill + relance de l'app.
- [ ] Le compteur de recettes créées dans Profil affiche le bon chiffre.
- [ ] Le bouton « Réinitialiser » supprime bien tout (avec confirmation).
- [ ] Le bouton « Restaurer » re-seed les recettes d'exemple.

---

# FAQ — Problèmes courants

### « Cannot convert struct Recipe... »

Quelque part dans le code, vous référencez encore l'ancien `Recipe` struct. Faites `Cmd + Shift + F` (Find in Project) sur `Recipe(id:` ou autres usages anciens.

### « No suitable model in scope »

Vous avez oublié `import SwiftData` en haut du fichier qui utilise `@Model`, `@Query` ou `@Environment(\.modelContext)`.

### « ModelContainer was nil »

La vue affichée en Preview n'a pas de container. Ajouter `.modelContainer(for: Recipe.self, inMemory: true)` à la Preview.

### Les recettes apparaissent en double au lancement

`MockData.seedIfNeeded` est appelé à chaque démarrage mais ne vérifie pas correctement. Vérifiez la condition `count == 0` et que vous appelez bien `try? context.save()` à la fin du seed.

### Les modifications ne sont pas sauvegardées

SwiftData sauvegarde automatiquement, mais avec un léger délai. Pour forcer : `try? context.save()`. Ou attendre quelques secondes avant de killer l'app.

### `@Query` ne se rafraîchit pas

Vérifiez que la propriété est bien `private var ...` et pas `let`. SwiftUI a besoin que ce soit une propriété observée.

### Le fichier SQLite : où est-il ?

Dans le sandbox de l'app :
```
~/Library/Developer/CoreSimulator/Devices/{UUID-simulateur}/data/Containers/Data/Application/{UUID-app}/Library/Application Support/default.store
```

Pour le voir : `xcrun simctl get_app_container booted com.example.MyRecipes data` dans le Terminal.

### Comment réinitialiser COMPLÈTEMENT la base ?

Dans le menu du simulateur : **Device → Erase All Content and Settings**. Cela efface tout, comme un iPhone neuf.

---

# Pour aller plus loin

À la fin de cette séance, vous savez :

- Convertir un modèle Swift (struct) en entité persistée (@Model class).
- Configurer un `ModelContainer` au niveau App.
- Récupérer un `ModelContext` via `@Environment` dans une vue.
- Utiliser `@Query` pour lire ET observer des données persistées.
- Filtrer avec `#Predicate` (compilé en SQL).
- Créer (`context.insert`), supprimer (`context.delete`), modifier (assignation directe).
- Gérer les relations entre modèles avec `@Relationship`.
- Migrer des Previews vers `inMemory: true`.


Bon travail ! 🎉
