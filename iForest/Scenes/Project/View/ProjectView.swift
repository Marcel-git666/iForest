//
//  ProjectView.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI

struct ProjectView: View {
    @StateObject private var store: ProjectViewStore
    
    init(store: ProjectViewStore) {
        _store = .init(wrappedValue: store)
    }
    var body: some View {
        NavigationStack {
            VStack {
                // Custom Navigation Title
                Text("Projects")
                    .textTypeModifier(textType: .navigationTitle) // Apply custom font
                    .padding(.top, 20) // Adjust for the space you'd expect for a title
                
                // Project List
                List(store.projects) { project in
                    Text(project.name)
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
    ProjectView(store: ProjectViewStore())
}
