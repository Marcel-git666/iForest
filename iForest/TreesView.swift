//
//  TreesView.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

struct Tree: Hashable {
    var name: String
}

struct TreesView: View {
    var stand: Stand

    var body: some View {
        List {
            ForEach([Tree(name: "Tree 1"), Tree(name: "Tree 2")], id: \.self) { tree in
                Text(tree.name)
            }
        }
        .navigationTitle("\(stand.name) - Trees")
    }
}


//#Preview {
//    TreesView()
//}
