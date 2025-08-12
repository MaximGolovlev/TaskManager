//
//  MainTabView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var dataController: DataController
    let persistenceController = DataController.shared
    
    var body: some View {
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.fill")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(EarthyColors.primary)
        .environmentObject(dataController)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
