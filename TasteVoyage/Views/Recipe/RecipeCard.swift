//
//  Untitled.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI

struct RecipeCard: View {
    @EnvironmentObject var dataController: DataController
    let recipe: RecipeEntity
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topTrailing) {
                if let image = recipe.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 120)
                }
                
                Button(action: { dataController.toggleFavorite(recipe) }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(recipe.isFavorite ? .red : EarthyColors.lightText)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                }
                .padding(4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.wrappedName)
                    .font(.headline)
                    .foregroundColor(EarthyColors.text)
                    .lineLimit(1)
                
                Text(recipe.wrappedCategory)
                    .font(.caption)
                    .foregroundColor(EarthyColors.secondary)
                
                HStack {
                    Label("\(recipe.ingredientsArray.count)", systemImage: "fork.knife")
                        .font(.caption)
                        .foregroundColor(EarthyColors.text.opacity(0.7))
                    
                    Spacer()
                    
                    Label("\(recipe.stepsArray.count)", systemImage: "list.number")
                        .font(.caption)
                        .foregroundColor(EarthyColors.text.opacity(0.7))
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(EarthyColors.cardBackground)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
