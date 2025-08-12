//
//  AddEditRecipeView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct AddEditRecipeView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    var recipe: RecipeEntity?
    
    @State private var name: String = ""
    @State private var category: String = ""
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    @State private var isFavorite: Bool = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var showingCategoryInput = false
    @State private var newCategory: String = ""
    
    let predefinedCategories = ["Breakfast", "Lunch", "Dinner", "Dessert", "Snack", "Drink"]
    
    // Performance optimization
    @State private var loaded = false
    
    init(recipe: RecipeEntity? = nil) {
        self.recipe = recipe
    }
    
    var allCategories: [String] {
        let existingCategories = Set(dataController.recipes.map { $0.wrappedCategory })
        let predefined = Set(predefinedCategories)
        return Array(predefined.union(existingCategories)).sorted()
    }
    
    var body: some View {
        NavigationStack {
            List {
                imageSection
                informationSection
                ingredientsSection
                stepsSection

                if recipe != nil {
                    favouriteSection
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle(recipe == nil ? "Add Recipe" : "Edit Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(EarthyColors.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(recipe == nil ? "Add" : "Save") {
                        saveRecipe()
                        dismiss()
                    }
                    .foregroundColor(EarthyColors.primary)
                    .disabled(name.isEmpty || category.isEmpty)
                    .opacity(name.isEmpty || category.isEmpty ? 0.5 : 1.0)
                }
            }
            .alert("New Category", isPresented: $showingCategoryInput) {
                TextField("Category name", text: $newCategory)
                Button("Add") {
                    if !newCategory.isEmpty {
                        category = newCategory
                        newCategory = ""
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .background(EarthyColors.background)
            .onAppear {
                guard !loaded else { return }
                loadInitialData()
                loaded = true
            }
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                if let uiImage = image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }
                
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Text("Select Image")
                        .foregroundColor(EarthyColors.primary)
                }
                .onChange(of: selectedImage) { _ in
                    Task {
                        if let data = try? await selectedImage?.loadTransferable(type: Data.self) {
                            image = UIImage(data: data)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(EarthyColors.cardBackground)
    }
    
    private var informationSection: some View {
        Section(header: Text("Recipe Information")) {
            TextField("Name", text: $name)
            
            Picker("Category", selection: $category) {
                Text("Select a category").tag("")
                ForEach(allCategories, id: \.self) { cat in
                    Text(cat).tag(cat)
                }
            }
            
            Button("Add New Category") {
                showingCategoryInput = true
            }
            .foregroundColor(EarthyColors.primary)
        }
        .listRowBackground(EarthyColors.cardBackground)
    }
    
    private var ingredientsSection: some View {
        Section(header: Text("Ingredients")) {
            ForEach(ingredients.indices, id: \.self) { index in
                TextField("Ingredient \(index + 1)", text: $ingredients[index])
            }
            .onDelete { indices in
                ingredients.remove(atOffsets: indices)
            }
            
            Button(action: {
                ingredients.append("")
            }) {
                Label("Add Ingredient", systemImage: "plus")
                    .foregroundColor(EarthyColors.primary)
            }
        }
        .listRowBackground(EarthyColors.cardBackground)
    }
    
    private var stepsSection: some View {
        Section(header: Text("Steps")) {
            ForEach(steps.indices, id: \.self) { index in
                TextField("Step \(index + 1)", text: $steps[index], axis: .vertical)
            }
            .onDelete { indices in
                steps.remove(atOffsets: indices)
            }
            
            Button(action: {
                steps.append("")
            }) {
                Label("Add Step", systemImage: "plus")
                    .foregroundColor(EarthyColors.primary)
            }
        }
        .listRowBackground(EarthyColors.cardBackground)
    }
    
    private var favouriteSection: some View {
        Section {
            Toggle("Favorite", isOn: $isFavorite)
        }
        .listRowBackground(EarthyColors.cardBackground)
    }
    
    private func loadInitialData() {
        guard let recipe = recipe else { return }
        name = recipe.wrappedName
        category = recipe.wrappedCategory
        ingredients = recipe.ingredientsArray
        steps = recipe.stepsArray
        isFavorite = recipe.isFavorite
        image = recipe.uiImage
    }
    
    private func saveRecipe() {
        if let recipe = recipe {
            dataController.updateRecipe(
                recipe,
                name: name,
                category: category,
                ingredients: ingredients.filter { !$0.isEmpty },
                steps: steps.filter { !$0.isEmpty },
                isFavorite: isFavorite,
                image: image
            )
        } else {
            dataController.addRecipe(
                name: name,
                category: category,
                ingredients: ingredients.filter { !$0.isEmpty },
                steps: steps.filter { !$0.isEmpty },
                isFavorite: isFavorite,
                image: image
            )
        }
    }
}
