//
//  ProjectsView.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

struct Project: Hashable {
    var name: String
}

struct ProjectsView: View {
    struct Output {
        var goToStands: (Project) -> Void
    }

    var output: Output

    var body: some View {
        List {
            ForEach([Project(name: "Project A"), Project(name: "Project B")], id: \.self) { project in
                Button(project.name, action: {
                    output.goToStands(project)
                })
            }
        }
        .navigationTitle("Projects")
    }
}


#Preview {
    ProjectsView(output: .init(goToStands: {_ in }))
}
