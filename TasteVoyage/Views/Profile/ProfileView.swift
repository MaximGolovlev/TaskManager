//
//  ProfileView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataController: DataController
    @State private var isEditing = false
    
    var recipesCount: Int {
        dataController.recipes.count
    }
    
    var favoritesCount: Int {
        dataController.favoriteRecipes().count
    }
    
    var body: some View {
        NavigationStack {
            if let profile = dataController.userProfile {
                VStack(spacing: 20) {
                    if let image = profile.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(EarthyColors.accent, lineWidth: 4))
                            .shadow(radius: 10)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(EarthyColors.secondary)
                    }
                    
                    VStack(spacing: 8) {
                        Text(profile.wrappedName)
                            .font(.title)
                            .foregroundColor(EarthyColors.text)
                        
                        Text(profile.wrappedBio)
                            .font(.subheadline)
                            .foregroundColor(EarthyColors.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        HStack {
                            VStack {
                                Text("\(recipesCount)")
                                    .font(.title2)
                                    .foregroundColor(EarthyColors.primary)
                                Text("Recipes")
                                    .font(.subheadline)
                                    .foregroundColor(EarthyColors.text.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                                .frame(height: 50)
                            
                            VStack {
                                Text("\(favoritesCount)")
                                    .font(.title2)
                                    .foregroundColor(EarthyColors.primary)
                                Text("Favorites")
                                    .font(.subheadline)
                                    .foregroundColor(EarthyColors.text.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(EarthyColors.cardBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") {
                            isEditing = true
                        }
                        .foregroundColor(EarthyColors.primary)
                    }
                }
                .sheet(isPresented: $isEditing) {
                    EditProfileView()
                }
                .background(EarthyColors.background)
            } else {
                Text("Loading profile...")
                    .navigationTitle("Profile")
            }
        }
    }
}
