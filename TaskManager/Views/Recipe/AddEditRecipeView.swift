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
    
    init(recipe: RecipeEntity? = nil) {
        self.recipe = recipe
        if let recipe = recipe {
            _name = State(initialValue: recipe.wrappedName)
            _category = State(initialValue: recipe.wrappedCategory)
            _ingredients = State(initialValue: recipe.ingredientsArray)
            _steps = State(initialValue: recipe.stepsArray)
            _isFavorite = State(initialValue: recipe.isFavorite)
            _image = State(initialValue: recipe.uiImage)
        }
    }
    
    var allCategories: [String] {
        let existingCategories = Set(dataController.recipes.map { $0.wrappedCategory })
        let predefined = Set(predefinedCategories)
        return Array(predefined.union(existingCategories)).sorted()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                EarthyColors.background
                    .ignoresSafeArea()
                Form {
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
                    
                    if recipe != nil {
                        Section {
                            Toggle("Favorite", isOn: $isFavorite)
                        }
                        .listRowBackground(EarthyColors.cardBackground)
                    }
                }
            }
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
        }
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
