//
//  TaskManagerApp.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 11.08.2025.
//

import SwiftUI

@main
struct TaskManagerApp: App {
    
    @StateObject private var recipeStore = DataController()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(recipeStore)
                .preferredColorScheme(.light)
        }
    }
}
