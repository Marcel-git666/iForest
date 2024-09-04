//
//  TreesCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

final class TreesCoordinator: Hashable {
    @Binding var navigationPath: NavigationPath
    var stand: Stand

    private var id = UUID()

    init(navigationPath: Binding<NavigationPath>, stand: Stand) {
        self._navigationPath = navigationPath
        self.stand = stand
    }

    @ViewBuilder
    func view() -> some View {
        TreesView(stand: stand)
    }

    static func == (lhs: TreesCoordinator, rhs: TreesCoordinator) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
