//
//  TreeViewAction.swift
//  iForest
//
//  Created by Marcel Mravec on 28.09.2024.
//

import Foundation

enum TreeViewAction {
    case fetchTrees
    case createOrUpdateTree(tree: Tree)
    case deleteTree(Tree)
}
