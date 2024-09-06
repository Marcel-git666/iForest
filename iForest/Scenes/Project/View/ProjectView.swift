//
//  ProjectView.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import SwiftUI

struct ProjectView: View {
    @StateObject private var store: ProjectViewStore
    
    init(store: ProjectViewStore) {
        _store = .init(wrappedValue: store)
    }
    var body: some View {
        ZStack {
            Color.cyan
            Text("Projects")
                .textTypeModifier(textType: .navigationTitle)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ProjectView(store: ProjectViewStore())
}
