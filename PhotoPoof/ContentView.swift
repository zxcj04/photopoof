//
//  ContentView.swift
//  PhotoPoof
//
//  Created by FanRende on 2021/12/2.
//

import SwiftUI

struct ContentView: View {
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSource = 0
    
    func reset() {
        self.inputImage = nil
        self.showingImagePicker = false
    }
    
    func loadImage() {
    }
    
    var hasImage: Bool {
        inputImage != nil
    }

    var body: some View {
        let hasImageBinding = Binding<Bool> {
            hasImage
        } set: {_ in
            reset()
        }

        NavigationView {
            ZStack {
                BackgroundColor(color: hasImage ? Color.green: Color.gray)
                
                VStack {
                    ImagePickerView(showingImagePicker: $showingImagePicker, imageSource: $imageSource)
                        .opacity(hasImage ? 0: 1)
                        .animation(.easeOut, value: hasImage)

                    NavigationLink {
                        NoteView()
                    } label: {
                        HStack {
                            Image(systemName: "note.text")
                                .font(.system(size: 20))
                            Text("Make a Note")
                                .font(.headline)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                }
                
                if hasImage {
                    NavigationLink(isActive: hasImageBinding) {
                        PhotoEditView(image: inputImage!)
                    } label: {EmptyView()}
                }
            }
            .animation(.easeInOut, value: hasImage)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage, imageSource: self.$imageSource)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct BackgroundColor: View {
    var color: Color

    var body: some View {
        color
            .opacity(0.75)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
