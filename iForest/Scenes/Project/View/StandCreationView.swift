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
    @State private var shape: Stand.Shape = .circular // Include shape
    
    init(store: StandViewStore, stand: Stand? = nil) {
        self.store = store
        self.stand = stand
        _standName = State(initialValue: stand?.name ?? "")
        _standSize = State(initialValue: stand != nil ? "\(stand!.size)" : "")
        _shape = State(initialValue: stand?.shape ?? .circular) // Set initial value for shape
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
            
            Button(action: {
                if !standName.isEmpty, let size = Double(standSize) {
                    print("Save button tapped with name: \(standName) and size: \(size)") // Add this line for debugging
                    
                    // Call the appropriate store action to either create or update the stand
                    if let stand = stand {
                        store.send(.updateStand(stand, newName: standName, newSize: size, newShape: shape))
                    } else {
                        store.send(.createStand(name: standName, size: size, shape: shape))
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
        }
        .padding()
    }
}


#Preview {
    StandCreationView(store: StandViewStore(firestoreManager: LocalDataManager(), projectId: "1"))
}
