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
                case .initial:
                    List {
                        ForEach(store.projects) { project in
                            HStack {
                                Text(project.name)
                                Spacer()
                                Button(action: {
                                    projectToUpdate = project
                                    updatedProjectName = project.name
                                    showingUpdateAlert = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                Button(action: {
                                    store.deleteProject(project)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                case .empty:
                    Text("No Projects Available")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                
                // Create Project Button
                Button(action: {
                    store.send(.openCreateProjectView)
                }) {
                    Text("Create Project")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
            .toolbar {
                // Custom Toolbar for Logout Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        store.send(.logout)
                    }) {
                        Text("Logout")
                    }
                }
            }
        }
    }
}

#Preview {
    ProjectView(store: ProjectViewStore(firestoreManager: FirestoreManager()))
}
