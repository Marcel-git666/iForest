//
//  StandsView.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import SwiftUI

struct StandView: View {
    @ObservedObject var store: StandViewStore

    @State private var showingUpdateAlert = false
    @State private var standToUpdate: Stand?
    @State private var updatedStandName = ""
    @State private var updatedStandSize = ""
    @State private var updatedStandShape: Stand.Shape = .circular // Default shape

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
                                Text("Shape: \(stand.shape.rawValue.capitalized)") // Show shape
                                    .font(.caption)
                            }
                            Spacer()
                            Button(action: {
                                standToUpdate = stand
                                updatedStandName = stand.name
                                updatedStandSize = "\(stand.size)"
                                updatedStandShape = stand.shape // Set the initial shape value
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
                print("Create Stand button tapped")
                store.sendEvent(.createStandView)
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
            
            // Shape Picker
            Picker("Shape", selection: $updatedStandShape) {
                Text("Circular").tag(Stand.Shape.circular)
                Text("Square").tag(Stand.Shape.square)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button("Save", action: {
                if let stand = standToUpdate, let size = Double(updatedStandSize) {
                    store.send(.updateStand(stand, newName: updatedStandName, newSize: size, newShape: updatedStandShape)) // Pass the shape as well
                }
            })
            Button("Cancel", role: .cancel, action: {})
        })
    }
}

#Preview {
    StandView(store: StandViewStore(firestoreManager: LocalDataManager(), projectId: "123"))
}
