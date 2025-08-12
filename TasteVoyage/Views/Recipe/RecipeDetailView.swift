//
//  RecipeDetailView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @ObservedObject var recipe: RecipeEntity
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe image
                ZStack(alignment: .topTrailing) {
                    if let image = recipe.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(height: 250)
                    }
                    
                    Button(action: { dataController.toggleFavorite(recipe) }) {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(recipe.isFavorite ? .red : EarthyColors.lightText)
                            .padding(12)
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                    .padding()
                }
                
                // Recipe info
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(recipe.wrappedName)
                            .font(.title)
                            .foregroundColor(EarthyColors.text)
                        
                        Spacer()
                        
                        Text(recipe.wrappedCategory)
                            .font(.subheadline)
                            .padding(8)
                            .background(EarthyColors.secondary)
                            .foregroundColor(EarthyColors.lightText)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients")
                            .font(.headline)
                            .foregroundColor(EarthyColors.primary)
                        
                        ForEach(recipe.ingredientsArray.indices, id: \.self) { index in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(recipe.ingredientsArray[index])
                            }
                            .foregroundColor(EarthyColors.text)
                        }
                    }
                    
                    Divider()
                    
                    // Steps
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(EarthyColors.primary)
                        
                        ForEach(recipe.stepsArray.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                    Text(recipe.stepsArray[index])
                                }
                                .foregroundColor(EarthyColors.text)
                                
                                if index < recipe.stepsArray.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
                .foregroundColor(EarthyColors.primary)
            }
        }
        .sheet(isPresented: $isEditing) {
            AddEditRecipeView(recipe: recipe)
        }
        .background(EarthyColors.background)
    }
}
