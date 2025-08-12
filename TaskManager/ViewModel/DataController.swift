//
//  DataController.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI
import CoreData

// MARK: - Data Controller
class DataController: ObservableObject {
    static let shared = DataController()
    
    @Published var recipes: [RecipeEntity] = []
    @Published var userProfile: UserProfileEntity?
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeApp")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load CoreData stores: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        createDefaultProfileIfNeeded()
        
        fetchRecipes()
        fetchProfile()
    }
}


extension DataController {
    // MARK: - Recipe Management
    
    func addRecipe(name: String, category: String, ingredients: [String], steps: [String], isFavorite: Bool = false, image: UIImage? = nil) {
        let context = container.viewContext
        let recipe = RecipeEntity(context: context)
        
        recipe.id = UUID()
        recipe.name = name
        recipe.category = category
        recipe.ingredients = ingredients.joined(separator: ";;")
        recipe.steps = steps.joined(separator: ";;")
        recipe.isFavorite = isFavorite
        recipe.createdAt = Date()
        
        if let image = image {
            recipe.imagePath = saveImageToFile(image: image, id: recipe.id ?? UUID())
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving recipe: \(error.localizedDescription)")
            context.delete(recipe)
        }
        
        fetchRecipes()
    }
    
    func updateRecipe(_ recipe: RecipeEntity, name: String, category: String, ingredients: [String], steps: [String], isFavorite: Bool, image: UIImage?) {
        let context = container.viewContext
        
        recipe.name = name
        recipe.category = category
        recipe.ingredients = ingredients.joined(separator: ";;")
        recipe.steps = steps.joined(separator: ";;")
        recipe.isFavorite = isFavorite
        
        if let image = image {
            if let oldPath = recipe.imagePath {
                deleteImage(at: oldPath)
            }
            recipe.imagePath = saveImageToFile(image: image, id: recipe.id ?? UUID())
        }
        
        do {
            try context.save()
        } catch {
            print("Error updating recipe: \(error.localizedDescription)")
        }
        
        fetchRecipes()
    }
    
    func deleteRecipe(_ recipe: RecipeEntity) {
        let context = container.viewContext
        
        if let imagePath = recipe.imagePath {
            deleteImage(at: imagePath)
        }
        
        context.delete(recipe)
        
        do {
            try context.save()
        } catch {
            print("Error deleting recipe: \(error.localizedDescription)")
        }
        
        fetchRecipes()
    }
    
    func toggleFavorite(_ recipe: RecipeEntity) {
        let context = container.viewContext
        recipe.isFavorite.toggle()
        
        do {
            try context.save()
        } catch {
            print("Error toggling favorite: \(error.localizedDescription)")
        }
        
        fetchRecipes()
    }
    
    func fetchRecipes() {
        let context = container.viewContext
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecipeEntity.createdAt, ascending: false)]
        
        do {
            recipes = try context.fetch(request)
        } catch {
            print("Error fetching recipes: \(error.localizedDescription)")
        }
    }
    
    func favoriteRecipes() -> [RecipeEntity] {
        let context = container.viewContext
        let request: NSFetchRequest<RecipeEntity> = RecipeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \RecipeEntity.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching favorite recipes: \(error.localizedDescription)")
            return []
        }
    }
    
}


extension DataController {
    
    fileprivate func createDefaultProfileIfNeeded() {
        let context = container.viewContext
        
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                let profile = UserProfileEntity(context: context)
                profile.name = "User Name"
                profile.bio = "Food enthusiast"
                try context.save()
            }
        } catch {
            print("Error checking for default profile: \(error.localizedDescription)")
        }
        
        fetchProfile()
    }
    
    // MARK: - User Profile Management
    
    func updateProfile(name: String, bio: String, image: UIImage?) {
        let context = container.viewContext
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            let profiles = try context.fetch(request)
            if let profile = profiles.first {
                profile.name = name
                profile.bio = bio
                
                if let image = image {
                    if let oldPath = profile.imagePath {
                        deleteImage(at: oldPath)
                    }
                    profile.imagePath = saveImageToFile(image: image, id: UUID())
                } else if profile.imagePath != nil {
                    deleteImage(at: profile.imagePath!)
                    profile.imagePath = nil
                }
                
                try context.save()
            }
        } catch {
            print("Error updating profile: \(error.localizedDescription)")
        }
        
        fetchProfile()
    }
    
    func fetchProfile() {
        let context = container.viewContext
        let request: NSFetchRequest<UserProfileEntity> = UserProfileEntity.fetchRequest()
        
        do {
            userProfile = try context.fetch(request).first
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }
}

extension DataController {
    // MARK: - Image Handling
    
    private func saveImageToFile(image: UIImage, id: UUID) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = "\(id.uuidString).jpg"
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func deleteImage(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}
