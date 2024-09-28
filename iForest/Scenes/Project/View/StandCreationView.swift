//
//  StandCreationView.swift
//  iForest
//
//  Created by Marcel Mravec on 27.09.2024.
//

import SwiftUI

struct StandCreationView: View {
    @ObservedObject var store: StandViewStore
    var stand: Stand? = nil
    @State private var standName: String = ""
    @State private var standSize: String = ""
    @State private var shape: Stand.Shape = .circular // Default shape

    init(store: StandViewStore, stand: Stand? = nil) {
        self.store = store
        self.stand = stand
        _standName = State(initialValue: stand?.name ?? "")
        _standSize = State(initialValue: stand != nil ? "\(stand!.size)" : "")
        _shape = State(initialValue: stand?.shape ?? .circular)
    }

    var body: some View {
        VStack {
            Text(stand != nil ? "Update Stand" : "Create New Stand")
                .textTypeModifier(textType: .navigationTitle)
                .padding(.top, 20)

            TextField("Stand Name", text: $standName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Size", text: $standSize)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Picker("Shape", selection: $shape) {
                Text("Circular").tag(Stand.Shape.circular)
                Text("Square").tag(Stand.Shape.square)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Save Button: Triggers either update or create
            Button(action: {
                if !standName.isEmpty, let size = Double(standSize) {
                    if let stand = stand {
                        store.send(.updateStand(stand, newName: standName, newSize: size, newShape: shape)) // Trigger update action
                    } else {
                        store.send(.createStand(name: standName, size: size, shape: shape)) // Trigger create action
                    }
                }
            }) {
                Text(stand != nil ? "Update Stand" : "Save Stand")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()

            // Cancel Button: Sends event to navigate back
            Button(action: {
                store.sendEvent(.backToProject) // Send event to navigate back
            }) {
                Text("Cancel")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}




#Preview {
    StandCreationView(store: StandViewStore(firestoreManager: LocalDataManager(), projectId: "1"))
}
