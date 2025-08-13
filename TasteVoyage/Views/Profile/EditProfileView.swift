//
//  EditProfileView.swift
//  TaskManager
//
//  Created by Maxim Golovlev on 12.08.2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var selectedImage: PhotosPickerItem?
    
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var image: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Image")) {
                    HStack {
                        Spacer()
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding()
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Label("Select Photo", systemImage: "photo")
                            .foregroundColor(EarthyColors.primary)
                    }
                    .onChange(of: selectedImage) { _ in
                        Task {
                            if let data = try? await selectedImage?.loadTransferable(type: Data.self) {
                                image = UIImage(data: data)
                            }
                        }
                    }
                    
                    if image != nil {
                        Button(role: .destructive) {
                            image = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                }
                .listRowBackground(EarthyColors.cardBackground)
                
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $name)
                    TextField("Bio", text: $bio)
                }
                .listRowBackground(EarthyColors.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(EarthyColors.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataController.updateProfile(name: name, bio: bio, image: image)
                        dismiss()
                    }
                    .foregroundColor(EarthyColors.primary)
                }
            }
            .background(EarthyColors.background)
            .onAppear() {
                name = dataController.userProfile?.wrappedName ?? ""
                bio = dataController.userProfile?.wrappedBio ?? ""
                image = dataController.userProfile?.uiImage
            }
        }
    }
}
