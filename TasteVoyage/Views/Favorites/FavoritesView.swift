//
//  FavoritesView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataController: DataController
    
    var favoriteRecipes: [RecipeEntity] {
        dataController.favoriteRecipes()
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if favoriteRecipes.isEmpty {
                    VStack {
                        Spacer()
                        Text("No favorites yet")
                            .font(.title)
                            .foregroundColor(EarthyColors.text)
                        Text("Add recipes to your favorites to see them here")
                            .foregroundColor(EarthyColors.text.opacity(0.7))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160)), GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(favoriteRecipes) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipeCard(recipe: recipe)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Favorites")
            .background(EarthyColors.background)
        }
    }
}
