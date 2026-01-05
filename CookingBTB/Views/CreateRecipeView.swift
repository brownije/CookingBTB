/// Recipe creation screen for user input
///
/// @author Joshua Browning

import SwiftUI
import Combine

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var estTime: String // Time to cook
    var serves: Int // # of people served (est.)
    var ingredients: [String]
    var steps: [String]
    var rating: Int // _/5 stars

    init(id: UUID = UUID(), title: String = "", estTime: String = "", serves: Int = 1, ingredients: [String] = [], steps: [String] = [], rating: Int = 0) {
        self.id = id
        self.title = title
        self.estTime = estTime
        self.serves = serves
        self.ingredients = ingredients
        self.steps = steps
        self.rating = rating
    }
}

final class RecipeStore: ObservableObject {
    static let shared = RecipeStore()
    @Published var recipes: [Recipe] = []
    init() {}
}

struct CreateRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = RecipeStore.shared

    @State private var title: String = ""
    @State private var estTime: String = ""
    @State private var serves: Int = 1
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    @State private var rating: Int = 0

    var body: some View {
        Form {
            Section("Title") {
                TextField("Recipe title", text: $title)
            }

            Section("Est. time") {
                TextField("e.g. 45 minutes", text: $estTime)
            }

            Section("Serves") {
                Stepper(value: $serves, in: 1...20) {
                    Text("Serves: \(serves)")
                }
            }

            Section("Ingredients") {
                ForEach(ingredients.indices, id: \.self) { idx in
                    HStack {
                        TextField("Ingredient", text: Binding(
                            get: { ingredients[idx] },
                            set: { ingredients[idx] = $0 }
                        ))
                        Button(role: .destructive) {
                            ingredients.remove(at: idx)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(ingredients.count == 1)
                    }
                }
                Button {
                    ingredients.append("")
                } label: {
                    Label("Add Ingredient", systemImage: "plus")
                }
            }

            Section("Steps") {
                ForEach(steps.indices, id: \.self) { idx in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(idx + 1).")
                            .foregroundStyle(.secondary)
                        TextField("Step description", text: Binding(
                            get: { steps[idx] },
                            set: { steps[idx] = $0 }
                        ), axis: .vertical)
                        .lineLimit(1...4)
                        Button(role: .destructive) {
                            steps.remove(at: idx)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(steps.count == 1)
                    }
                }
                Button {
                    steps.append("")
                } label: {
                    Label("Add step", systemImage: "plus")
                }
            }

            Section("Rating") {
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundStyle(star <= rating ? .yellow : .secondary)
                            .onTapGesture { rating = star }
                            .accessibilityLabel("Rate \(star) star\(star == 1 ? "" : "s")")
                    }
                    Spacer()
                    Text(rating == 0 ? "No rating" : "\(rating)/5")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Create Recipe")
        .toolbar { toolbar }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") { save() }
                .disabled(!canSave)
        }
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel") { dismiss() }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !ingredients.joined().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !steps.joined().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let cleanedIngredients = ingredients.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let cleanedSteps = steps.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let recipe = Recipe(title: title, estTime: estTime, serves: serves, ingredients: cleanedIngredients, steps: cleanedSteps, rating: rating)
        store.recipes.append(recipe)
        dismiss()
    }
}

#Preview {
    NavigationStack { CreateRecipeView() }
}
