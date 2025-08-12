//
//  RecipeListView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject var dataController: DataController
    @State private var showingAddRecipe = false
    @State private var selectedCategory: String? = nil
    
    var categories: [String] {
        Array(Set(dataController.recipes.map { $0.wrappedCategory })).sorted()
    }
    
    var filteredRecipes: [RecipeEntity] {
        if let category = selectedCategory {
            return dataController.recipes.filter { $0.wrappedCategory == category }
        }
        return dataController.recipes
    }
    
    private func deleteRecipe(_ recipe: RecipeEntity) {
        withAnimation {
            dataController.deleteRecipe(recipe)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataController.recipes.isEmpty {
                    VStack {
                        Spacer()
                        Text("No recipes yet")
                            .font(.title)
                            .foregroundColor(EarthyColors.text)
                        Text("Create your first recipe to get started")
                            .foregroundColor(EarthyColors.text.opacity(0.7))
                        Button(action: { showingAddRecipe = true }) {
                            Text("Add Recipe")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(EarthyColors.accent)
                                .foregroundColor(EarthyColors.lightText)
                                .cornerRadius(10)
                        }
                        .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            // Category filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    Button(action: { selectedCategory = nil }) {
                                        Text("All")
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == nil ? EarthyColors.primary : EarthyColors.secondary)
                                            .foregroundColor(EarthyColors.lightText)
                                            .cornerRadius(20)
                                    }
                                    
                                    ForEach(categories, id: \.self) { category in
                                        Button(action: { selectedCategory = category }) {
                                            Text(category)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedCategory == category ? EarthyColors.primary : EarthyColors.secondary)
                                                .foregroundColor(EarthyColors.lightText)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Recipe grid
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160)), GridItem(.adaptive(minimum: 160))], spacing: 16) {
                                ForEach(filteredRecipes, id: \.id) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCard(recipe: recipe)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    deleteRecipe(recipe)
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                            .swipeActions(edge: .trailing) {
                                                Button(role: .destructive) {
                                                    deleteRecipe(recipe)
                                                } label: {
                                                    Label("Delete", systemImage: "trash.fill")
                                                }
                                            }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("My Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(EarthyColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddEditRecipeView()
            }
            .background(EarthyColors.background)
        }
    }
}
