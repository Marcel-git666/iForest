//
//  StandsCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

final class StandsCoordinator: Hashable {
    @Binding var navigationPath: NavigationPath
    var project: Project

    private var id = UUID()

    init(navigationPath: Binding<NavigationPath>, project: Project) {
        self._navigationPath = navigationPath
        self.project = project
    }

    @ViewBuilder
    func view() -> some View {
        StandsView(project: project, output: .init(goToTrees: { stand in
            self.navigationPath.append(TreesCoordinator(navigationPath: self.$navigationPath, stand: stand))
        }))
    }

    static func == (lhs: StandsCoordinator, rhs: StandsCoordinator) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
