//
//  Untitled.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import UIKit
import SwiftUI

// MARK: - CoreData Models
extension RecipeEntity {
    var wrappedName: String {
        name ?? "Unknown Recipe"
    }
    
    var wrappedCategory: String {
        category ?? "Uncategorized"
    }
    
    var ingredientsArray: [String] {
        ingredients?.components(separatedBy: ";;") ?? []
    }
    
    var stepsArray: [String] {
        steps?.components(separatedBy: ";;") ?? []
    }
    
    var uiImage: UIImage? {
        guard let imagePath = imagePath else { return nil }
        return UIImage(contentsOfFile: imagePath)
    }
    
    var image: Image? {
        guard let uiImage = uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}

extension UserProfileEntity {
    var wrappedName: String {
        name ?? "User Name"
    }
    
    var wrappedBio: String {
        bio ?? "Food enthusiast"
    }
    
    var uiImage: UIImage? {
        guard let imagePath = imagePath else { return nil }
        return UIImage(contentsOfFile: imagePath)
    }
    
    var image: Image? {
        guard let uiImage = uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}
