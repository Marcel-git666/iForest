//
//  PhotoCaptureView.swift
//  iForest
//
//  Created by Marcel Mravec on 30.09.2024.
//

import SwiftUI
import AVFoundation

struct PhotoCaptureView: View {
    @ObservedObject var store: PhotoViewStore
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?

    var body: some View {
        VStack {
            Text("Capture Stand Photo")
                .font(.title)
                .padding()

            if let image = inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 300)
                    .cornerRadius(8)
                    .padding()
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth: 300, maxHeight: 300)
                    .cornerRadius(8)
                    .padding()
            }

            Button("Take Photo") {
                showImagePicker = true
            }
            .buttonStyle(PlainButtonStyle())
            .padding()

            Button("Save Photo") {
                if let inputImage = inputImage {
                    store.send(.savePhoto(inputImage))
                } else {
                    print("No image selected")
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding()

            Button("Cancel") {
                store.send(.cancel)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            if let image = inputImage {
                store.send(.savePhoto(image))
            }
        }) {
            ImagePicker(image: $inputImage)
        }
    }
}

#Preview {
    PhotoCaptureView(store: PhotoViewStore())
}

