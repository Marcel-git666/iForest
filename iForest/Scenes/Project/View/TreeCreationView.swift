//
//  TreeCreationView.swift
//  iForest
//
//  Created by Marcel Mravec on 28.09.2024.
//

import SwiftUI

import SwiftUI

struct TreeCreationView: View {
    @ObservedObject var store: TreeViewStore
    var tree: Tree? = nil
    @State private var treeName: String = ""
    @State private var treeLocation: String = ""
    
    @State private var newHeight: String = ""
    @State private var newGirth: String = ""
    @State private var newDate = Date()
    
    // State for showing alerts
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(store: TreeViewStore, tree: Tree? = nil) {
        self.store = store
        self.tree = tree
        _treeName = State(initialValue: tree?.name ?? "")
        _treeLocation = State(initialValue: tree?.location ?? "")
    }
    
    var body: some View {
        VStack {
            Text(tree != nil ? "Update Tree" : "Create New Tree")
                .textTypeModifier(textType: .navigationTitle)
                .padding(.top, 20)
            
            TextField("Tree Name", text: $treeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Location", text: $treeLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if let measurements = tree?.measurements {
                List {
                    ForEach(measurements) { measurement in
                        HStack {
                            Text("Height: \(measurement.height) m")
                            Text("Girth: \(measurement.girth) cm")
                            Text("Date: \(measurement.date, formatter: dateFormatter)")
                        }
                    }
                }
            }
            
            HStack {
                TextField("Height (m)", text: $newHeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Girth (cm)", text: $newGirth)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker("Date", selection: $newDate, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()
            
            // Unified button for adding a measurement and updating the tree
            Button(action: {
                updateTreeWithOptionalMeasurement()
            }) {
                Text(tree != nil ? "Update Tree" : "Save Tree")
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
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func updateTreeWithOptionalMeasurement() {
        // Validate tree name and location
        guard !treeName.isEmpty else {
            alertMessage = "Tree name is required."
            showingAlert = true
            return
        }
        
        // If both height and girth are valid, create a new measurement; otherwise, ignore it
        var newMeasurements = tree?.measurements ?? []
        if let height = Double(newHeight), let girth = Double(newGirth), !newHeight.isEmpty && !newGirth.isEmpty {
            let newMeasurement = Measurement(id: UUID().uuidString, date: newDate, height: height, girth: girth)
            newMeasurements.append(newMeasurement)
        }
        
        // Create or update the tree
        let updatedTree = Tree(
            id: tree?.id ?? UUID().uuidString,
            name: treeName,
            location: treeLocation,
            measurements: newMeasurements
        )
        
        // Send the update to the store
        store.send(.createOrUpdateTree(tree: updatedTree))
    }
}

private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}

#Preview {
    TreeCreationView(store: TreeViewStore(dataManager: LocalDataManager(), standId: "456456"))
}
