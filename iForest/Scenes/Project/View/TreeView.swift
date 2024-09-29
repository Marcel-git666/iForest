//
//  TreeView.swift
//  iForest
//
//  Created by Marcel Mravec on 28.09.2024.
//

import SwiftUI

struct TreeView: View {
    @ObservedObject var store: TreeViewStore
    
    @State private var selectedTree: Tree? = nil
    
    var body: some View {
        VStack {
            Text("Trees")
                .textTypeModifier(textType: .navigationTitle)

            switch store.state.status {
            case .loading:
                ProgressView("Loading trees...")
                
            case .loaded:
                List {
                    ForEach(store.trees) { tree in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tree.name)
                                Text("Size: \(tree.size)")
                                    .font(.caption)
                                Text("Location: \(tree.location)")
                                    .font(.caption2)
                            }
                            Spacer()
                            Button(action: {
                                selectedTree = tree
                                store.sendEvent(.updateTreeView(tree))
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Button(action: {
                                store.send(.deleteTree(tree))
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
            case .empty:
                Text("No Trees Available")
                    .font(.title)
                    .foregroundColor(.gray)

            case .error:
                Text("Error loading trees")
                    .foregroundColor(.red)
            }
            
            Button(action: {
                store.sendEvent(.createTreeView)
            }) {
                Text("Create Tree")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
}

#Preview {
    TreeView(store: TreeViewStore(dataManager: LocalDataManager(), standId: "123"))
}
