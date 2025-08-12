import SwiftUI
import PhotosUI
import CoreData

// MARK: - Preview
struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        let dataController = DataController(inMemory: true)
        
        // Add some sample data
        let context = dataController.container.viewContext
        
        let profile = UserProfileEntity(context: context)
        profile.name = "John Doe"
        profile.bio = "Food enthusiast"
        
        let recipe1 = RecipeEntity(context: context)
        recipe1.id = UUID()
        recipe1.name = "Pasta Carbonara"
        recipe1.category = "Dinner"
        recipe1.ingredients = "Spaghetti;;Eggs;;Parmesan;;Pancetta;;Black pepper"
        recipe1.steps = "Cook pasta;;Fry pancetta;;Mix eggs and cheese;;Combine everything"
        recipe1.isFavorite = true
        recipe1.createdAt = Date()
        
        let recipe2 = RecipeEntity(context: context)
        recipe2.id = UUID()
        recipe2.name = "Avocado Toast"
        recipe2.category = "Breakfast"
        recipe2.ingredients = "Bread;;Avocado;;Salt;;Pepper;;Lemon juice"
        recipe2.steps = "Toast bread;;Mash avocado;;Spread on toast;;Season"
        recipe2.isFavorite = false
        recipe2.createdAt = Date().addingTimeInterval(-1000)
        
        try? context.save()
        
        return MainTabView()
            .environmentObject(dataController)
    }
}
