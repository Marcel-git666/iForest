//
//  TreeCreationView.swift
//  iForest
//
//  Created by Marcel Mravec on 28.09.2024.
//

import SwiftUI

struct TreeCreationView: View {
    @ObservedObject var store: TreeViewStore
    var tree: Tree? = nil
    @State private var treeName: String = ""
    @State private var treeSize: String = ""
    @State private var treeLocation: String = ""

    init(store: TreeViewStore, tree: Tree? = nil) {
        self.store = store
        self.tree = tree
        _treeName = State(initialValue: tree?.name ?? "")
        _treeSize = State(initialValue: tree != nil ? "\(tree!.size)" : "")
        _treeLocation = State(initialValue: tree?.location ?? "")
    }

    var body: some View {
        VStack {
            Text(tree != nil ? "Update Tree" : "Create New Tree")
                .textTypeModifier(textType: .navigationTitle)
                .padding(.top, 20)
            
            TextField("Tree Name", text: $treeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Size", text: $treeSize)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Location", text: $treeLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if let size = Double(treeSize), !treeName.isEmpty {
                    let newTree = Tree(
                        id: tree?.id ?? UUID().uuidString,
                        name: treeName,
                        size: size,
                        location: treeLocation,
                        measurements: tree?.measurements ?? []
                    )
                    store.send(.createOrUpdateTree(tree: newTree))
                }
            }) {
                Text(tree != nil ? "Update Tree" : "Save Tree")
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
    TreeCreationView(store: TreeViewStore(dataManager: LocalDataManager(), standId: "456456"))
}
