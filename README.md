# MyRecipes — Corrigé séance 5 (projet Xcode prêt à ouvrir)

Ce dossier contient un **projet Xcode complet** correspondant au corrigé du TP de la séance 5 (formulaires et workflow CRUD).

## Comment utiliser

1. Ouvrir Xcode (15 ou supérieur).
2. **File → Open…** et sélectionner `MyRecipes.xcodeproj`.
3. Sélectionner un simulateur (iPhone 15) et appuyer sur ▶ (`Cmd + R`).

Au lancement vous obtenez : la liste avec un bouton **+** en haut à droite, et un bouton **crayon** dans la barre de chaque vue détail.

## Ce qui a changé par rapport à la séance 4

Un fichier nouveau et trois fichiers modifiés :

```
MyRecipes/
├── MyRecipesApp.swift          ← inchangé
├── RootView.swift              ← inchangé
├── RecipeListView.swift        ← MODIFIÉ : bouton + et sheet de création
├── RecipeDetailView.swift      ← MODIFIÉ : bouton crayon et sheet d'édition
├── EditRecipeView.swift        ← NOUVEAU : le formulaire create/edit unifié
├── FavoritesView.swift         ← inchangé
├── ProfileView.swift           ← inchangé
├── RecipeCardView.swift        ← inchangé
├── RecipeStore.swift           ← MODIFIÉ : ajout de update(_:)
├── Recipe.swift                ← MODIFIÉ : ajout de isValid + emptyDraft
├── MockData.swift              ← inchangé
└── Assets.xcassets/
```

## Ce que démontre le corrigé

### Exercice 5.1 — EditRecipeView

`EditRecipeView.swift` est entièrement nouveau. Il utilise un `Form` avec 4 sections (Informations, Quantités, Ingrédients, Préparation). Tous les composants typés sont là : `TextField(axis: .vertical)`, `Stepper`, `Picker(.segmented)`, et l'itération avec Bindings via `ForEach($draft.ingredients)`. Le pattern « brouillon » : `@State var draft: Recipe` — une copie modifiable, jamais la recette originale. La présentation se fait via `.sheet(isPresented:)` + `.presentationDetents([.large])`.

### Exercice 5.2 — Validation

La computed property `Recipe.isValid` (dans `Recipe.swift`) centralise les 4 conditions (titre >= 3 caractères trimmé, durée > 0, portions > 0, au moins un ingrédient). Le bouton Enregistrer porte `.disabled(!draft.isValid)`. Sous le champ titre, un `if` conditionnel affiche un message rouge si le titre est non vide mais trop court. Le header de la section Ingrédients indique « (au moins un requis) » en rouge si la liste est vide.

### Exercice 5.3 — Édition unifiée

Un enum `Mode { case create, edit }` dans `EditRecipeView` change uniquement le titre de la nav bar. Le **comportement de sauvegarde** est délégué au parent via la closure `onSave: (Recipe) -> Void`. Le parent décide : `store.add(...)` pour création, `store.update(...)` pour édition. Le `Recipe.id` est PRÉSERVÉ dans `update`, donc pas de duplication.

Le bouton **crayon** (`square.and.pencil`) est ajouté dans la toolbar de `RecipeDetailView`. Il présente `EditRecipeView(mode: .edit, draft: recipe)` en sheet.

## Configuration

| Réglage | Valeur |
|---------|--------|
| iOS Deployment Target | 17.0 |
| Swift Version | 5.0 |
| Bundle Identifier | `com.example.MyRecipes` |
| Devices | iPhone + iPad |
| Previews | activées |

## Tester l'enchaînement

1. Lancer dans le simulateur.
2. Tap sur le **+** en haut à droite → la sheet de création apparaît.
3. Taper « Pad Thai », ajouter 2 ingrédients (avec quantité et unité), 2 étapes → le bouton Enregistrer s'active.
4. Enregistrer → la sheet se ferme, la nouvelle recette apparaît en tête de liste.
5. Tap sur Pad Thai → la vue détail s'ouvre.
6. Tap sur le **crayon** dans la barre du haut → la même sheet apparaît, pré-remplie.
7. Changer le titre en « Pad Thai aux crevettes » → Enregistrer.
8. Retour automatique à la vue détail mise à jour.
9. Retour à la liste : la recette a son nouveau titre. **Pas de duplication**.

## Tester la validation

1. Taper le **+** → sheet vide → le bouton Enregistrer est grisé.
2. Taper « Ab » dans le titre → message rouge « 3 caractères minimum ».
3. Taper « Abc » → le message disparaît mais Enregistrer reste grisé (pas d'ingrédients).
4. Ajouter un ingrédient → Enregistrer s'active.
5. Tap sur **Annuler** → la sheet se ferme, rien n'est sauvegardé.

## Comparer avec le sujet

- **Sujet pas-à-pas** : `Code/Seance_05/Exercices_Formulaires.md` (avec parties guidées 🟢 et autonomes 🟠)
- **Projet Xcode prêt à compiler** : ce dossier

Bon code ! 🎉
