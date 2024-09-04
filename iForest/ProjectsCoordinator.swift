//
//  ProjectsCoordinator.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

final class ProjectsCoordinator: Hashable {
    @Binding var navigationPath: NavigationPath

    private var id = UUID()

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    @ViewBuilder
    func view() -> some View {
        ProjectsView(output: .init(goToStands: { project in
            self.navigationPath.append(StandsCoordinator(navigationPath: self.$navigationPath, project: project))
        }))
    }

    static func == (lhs: ProjectsCoordinator, rhs: ProjectsCoordinator) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
