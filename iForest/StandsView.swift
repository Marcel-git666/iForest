//
//  StandsView.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

struct Stand: Hashable {
    var name: String
}

struct StandsView: View {
    var project: Project
    struct Output {
        var goToTrees: (Stand) -> Void
    }

    var output: Output

    var body: some View {
        List {
            ForEach([Stand(name: "Stand 1"), Stand(name: "Stand 2")], id: \.self) { stand in
                Button(stand.name, action: {
                    output.goToTrees(stand)
                })
            }
        }
        .navigationTitle("\(project.name) - Stands")
    }
}


//#Preview {
//    StandsView(project: .init(name: <#T##String#>), output: <#T##StandsView.Output#>)
//}
