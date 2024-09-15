//
//  ProjectCreationView.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import SwiftUI

struct ProjectCreationView: View {
    @State private var projectName: String = ""
    var onSave: (String) -> Void
    
    var body: some View {
        VStack {
            Text("Create New Project")
                .textTypeModifier(textType: .navigationTitle)
                .padding(.top, 20)
            
            TextField("Project Name", text: $projectName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !projectName.isEmpty {
                    onSave(projectName)
                }
            }) {
                Text("Save Project")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ProjectCreationView(onSave: { _ in })
}
