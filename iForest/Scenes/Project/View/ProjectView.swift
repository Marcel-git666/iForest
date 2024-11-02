//
//  ProjectView.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI

struct ProjectView: View {
    @ObservedObject var store: ProjectViewStore
    
    @State private var showingUpdateAlert = false
    @State private var projectToUpdate: Project?
    @State private var updatedProjectName = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Custom Navigation Title
                Text("Projects")
                    .textTypeModifier(textType: .navigationTitle)
                
                switch store.state.status {
                case .loading:
                    ProgressView("Loading projects...") // Handle loading state
                    
                case .loaded, .initial:
                    List {
                        ForEach(store.projects) { project in
                            HStack {
                                Text(project.name)
                                    .foregroundColor(.primary) // Adapts to light/dark mode
                                Spacer()
                                
                                // Edit Button
                                Button(action: {
                                    projectToUpdate = project
                                    updatedProjectName = project.name
                                    showingUpdateAlert = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Delete Button
                                Button(action: {
                                    store.deleteProject(project)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .contentShape(Rectangle()) // Makes the entire row tappable
                            .onTapGesture {
                                store.send(.openStands(project))
                            }
                        }
                    }
                    
                case .empty:
                    Text("No Projects Available")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                case .error:
                    Text("Error loading projects")
                        .font(.title)
                        .foregroundColor(.red)
                }
                
                // Create Project Button
                Button(action: {
                    store.send(.openCreateProjectView)
                }) {
                    Text("Create Project")
                        .foregroundColor(.white) // Button text
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor) // Adaptive button background
                        .cornerRadius(8)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("ProjectView access level: \(AppState.shared.accessLevel)")
                        if AppState.shared.accessLevel == .authorized {
                            store.send(.logout)
                        } else {
                            store.send(.login)
                        }
                    }) {
                        Text(AppState.shared.accessLevel == .authorized ? "Logout" : "Login")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground)) // Adapts to light/dark mode
        .alert("Update Project", isPresented: $showingUpdateAlert, actions: {
            TextField("Project Name", text: $updatedProjectName)
            Button("Save", action: {
                if let project = projectToUpdate {
                    store.updateProject(project, newName: updatedProjectName)
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
    }
}

#Preview {
    ProjectView(store: ProjectViewStore(dataManager: LocalDataManager()))
}
