//
//  StandCreationView.swift
//  iForest
//
//  Created by Marcel Mravec on 27.09.2024.
//

import SwiftUI

struct StandCreationView: View {
    var stand: Stand? = nil // Pass a stand if you are updating, leave nil if creating
    @State private var standName: String = ""
    @State private var standSize: String = ""
    var onSave: (String, Double) -> Void
    
    init(stand: Stand? = nil, onSave: @escaping (String, Double) -> Void) {
        self.stand = stand
        self.onSave = onSave
        _standName = State(initialValue: stand?.name ?? "")
        _standSize = State(initialValue: stand != nil ? "\(stand!.size)" : "")
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

            Button(action: {
                if !standName.isEmpty, let size = Double(standSize) {
                    onSave(standName, size)
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
    StandCreationView(onSave: { _, _ in })
}
