//
//  StandsView.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import SwiftUI

struct StandsView: View {
    @ObservedObject var store: StandsViewStore

    @State private var showingUpdateAlert = false
    @State private var standToUpdate: Stand?
    @State private var updatedStandName = ""
    @State private var updatedStandSize = ""

    var body: some View {
        VStack {
            Text("Stands")
                .textTypeModifier(textType: .navigationTitle)

            switch store.state.status {
            case .loading:
                ProgressView("Loading stands...")

            case .loaded:
                List {
                    ForEach(store.stands) { stand in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(stand.name)
                                Text("Size: \(stand.size)")
                                    .font(.caption)
                            }
                            Spacer()
                            Button(action: {
                                standToUpdate = stand
                                updatedStandName = stand.name
                                updatedStandSize = "\(stand.size)"
                                showingUpdateAlert = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            Button(action: {
                                store.send(.deleteStand(stand))
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }

            case .empty:
                Text("No Stands Available")
                    .font(.title)
                    .foregroundColor(.gray)

            case .error:
                Text("Error loading stands")
                    .foregroundColor(.red)
            }

            Button(action: {
                // Handle stand creation (you can add a new view or form here)
            }) {
                Text("Create Stand")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .alert("Update Stand", isPresented: $showingUpdateAlert, actions: {
            TextField("Name", text: $updatedStandName)
            TextField("Size", text: $updatedStandSize)
                .keyboardType(.decimalPad)
            Button("Save", action: {
                if let stand = standToUpdate, let size = Double(updatedStandSize) {
                    store.send(.updateStand(stand, newName: updatedStandName, newSize: size))
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
    }
}

#Preview {
    StandsView(store: StandsViewStore(firestoreManager: FirestoreManager(), projectId: "123"))
}
