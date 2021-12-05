//
//  ImagePickerView.swift
//  PhotoPoof
//
//  Created by FanRende on 2021/12/2.
//

import SwiftUI

struct ImagePickerView: View {
    @Binding var showingImagePicker: Bool
    @Binding var imageSource: Int

    var body: some View {
        Group {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    self.showingImagePicker = true
                    self.imageSource = 1
                } label: {
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 20))
                        Text("Take a Photo")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
            }
            
            Button {
                self.showingImagePicker = true
                self.imageSource = 0
            } label: {
                HStack {
                   Image(systemName: "photo")
                       .font(.system(size: 20))

                   Text("Photo library")
                       .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)
            }
        }
    }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(showingImagePicker: .constant(false), imageSource: .constant(0))
    }
}
