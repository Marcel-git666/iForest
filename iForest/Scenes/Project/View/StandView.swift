//
//  StandsView.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import SwiftUI

struct StandView: View {
    @ObservedObject var store: StandViewStore
    
    @State private var standToUpdate: Stand?
    @State private var updatedStandName = ""
    @State private var updatedStandSize = ""
    @State private var updatedStandShape: Stand.Shape = .circular // Default shape
    
    var body: some View {
        VStack {
            Text("Stands")
                .textTypeModifier(textType: .navigationTitle)
                .foregroundColor(.primary) 
            
            switch store.state.status {
            case .loading:
                ProgressView("Loading stands...")
                
            case .loaded:
                List {
                    ForEach(store.stands) { stand in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(stand.name)
                                    .foregroundColor(.primary) // Adapts to light/dark mode
                                Text("Size: \(stand.size)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            // Edit Button
                            Button(action: {
                                store.sendEvent(.updateStandView(stand))
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Capture Photo Button
                            Button(action: {
                                store.sendEvent(.capturePhoto(stand))
                            }) {
                                Image(systemName: "camera")
                                    .foregroundColor(.green)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Delete Button
                            Button(action: {
                                store.send(.deleteStand(stand))
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .contentShape(Rectangle()) // Makes the entire row tappable
                        .onTapGesture {
                            store.send(.openTrees(stand))
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
                store.sendEvent(.createStandView)
            }) {
                Text("Create Stand")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor) // Adaptive button color
                    .cornerRadius(8)
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground)) // Adaptive background color
    }
}

#Preview {
    StandView(store: StandViewStore(dataManager: LocalDataManager(), projectId: "123"))
}
