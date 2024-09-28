//
//  StandsView.swift
//  iForest
//
//  Created by Marcel Mravec on 15.09.2024.
//

import SwiftUI

struct StandView: View {
    @ObservedObject var store: StandViewStore

//    @State private var showingUpdateAlert = false
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
                            }
                            Spacer()
                            
                            // Edit Button
                            Button(action: {
                                store.sendEvent(.updateStandView(stand)) // Trigger event to open StandCreationView
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Delete Button
                            Button(action: {
                                store.send(.deleteStand(stand)) // Delete stand
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
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
    }
}

#Preview {
    StandView(store: StandViewStore(firestoreManager: LocalDataManager(), projectId: "123"))
}
