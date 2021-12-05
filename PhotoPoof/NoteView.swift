//
//  NoteView.swift
//  PhotoPoof
//
//  Created by FanRende on 2021/12/5.
//

import SwiftUI

struct NoteView: View {
    @State private var note = Note.defaultNote
    
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    @State private var imageSource = 0
    
    @State private var editorFrame = CGRect()
    @State private var goToPreview = false
    @State private var showSettings = true
    
    @FocusState private var keyboard: Bool
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    func loadImage() {
        guard let inputImage = inputImage else {return}
        note.images.append(inputImage)
        self.inputImage = nil
    }
    
    func getWeatherImage(weather: Int) -> Image {
        var imageName = ""

        switch weather {
        case 0:
            imageName = "sun.max"
        case 1:
            imageName = "wind"
        case 2:
            imageName = "cloud"
        case 3:
            imageName = "cloud.sun"
        case 4:
            imageName = "cloud.rain"
        default:
            imageName = ""
        }
        
        return Image(systemName: imageName)
    }

    var body: some View {
        ZStack {
            BackgroundColor(color: Color.gray)
            
            VStack(alignment: .leading) {
                Form {
                    Section {
                        TextField("Title", text: $note.title, prompt: Text("How's it going?"))
                            .font(.title)
                            .foregroundColor(note.fontColor)
                            .focused($keyboard)
                    }

                    DisclosureGroup("設定", isExpanded: $showSettings) {
                        DatePicker("Date", selection: $note.date)
                        Stepper(value: $note.weather, in: 0...4) {
                            getWeatherImage(weather: note.weather)
                        }
                        ColorPicker("Font Color", selection: $note.fontColor)
                        ColorPicker("Background Color", selection: $note.backgroundColor)
                    }

                    Section {
                        ZStack {
                            if note.content.isEmpty {
                                Text("Write something")
                                    .foregroundColor(.gray)
                                    .opacity(0.5)
                                    .padding(.all)
                                    .offset(x: -editorFrame.width * 0.5 + 65, y: -UIScreen.main.bounds.height * 0.1 + 20)
                            }

                            TextEditor(text: $note.content)
                                .frame(height: UIScreen.main.bounds.height * 0.2)
                                .foregroundColor(note.fontColor)
                                .overlay(
                                    GeometryReader(content: { geometry in
                                        Color.clear
                                            .onAppear(perform: {
                                                editorFrame = geometry.frame(in: .global)
                                            })
                                    })
                                )
                                .focused($keyboard)
                        }
                        
                        if !note.images.isEmpty {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(note.images, id: \.self) { image in
                                        let idx = note.images.firstIndex(of: image)!

                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: UIScreen.main.bounds.height * 0.1)
                                            .overlay(
                                                Button {
                                                    note.images.remove(at: idx)
                                                } label: {
                                                    Color(.white)
                                                        .frame(width: 15, height: 15)
                                                        .clipShape(Circle())
                                                        .overlay(
                                                            Image(systemName: "minus.circle.fill")
                                                                .resizable()
                                                                .frame(width: 13, height: 13)
                                                                .foregroundColor(.black)
                                                        )
                                                }
                                            )
                                    }
                                }
                            }
                        }

                        ImagePickerView(showingImagePicker: $showingImagePicker, imageSource: $imageSource)
                            .frame(height: UIScreen.main.bounds.height * 0.05)
                    }
                
                    Button {
                        self.goToPreview = true
                    } label: {
                        Label {
                            Text("Next")
                        } icon: {
                            Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                        }
                        .foregroundColor(.green)
                    }
                    
                }
                .padding()
                .background(note.backgroundColor)
            }
            .onChange(of: note.weather) { _ in
                self.keyboard = false
            }
            
            NavigationLink(isActive: $goToPreview) {
                SaveNoteView(note: self.note)
            } label: { EmptyView() }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage, imageSource: self.$imageSource)
        }
        .gesture(
            DragGesture()
                .onEnded { _ in
                    self.keyboard = false
                }
        )
        .navigationBarTitle("Create a Note")
    }
}

struct SaveNoteView: View {
    @State var note: Note
    @State var saveAlert = false
    
    var columnGrid = [
        [GridItem(.flexible())],
        [GridItem(.flexible()), GridItem(.flexible())],
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
    ]
    
    func getGridIdx() -> Int {
        if note.images.count == 1 {
            return 0
        }
        
        if note.images.count == 2 {
            return 1
        }
    
        return 2
    }
    
    func getWeatherImage(weather: Int) -> Image {
        var imageName = ""

        switch weather {
        case 0:
            imageName = "sun.max"
        case 1:
            imageName = "wind"
        case 2:
            imageName = "cloud"
        case 3:
            imageName = "cloud.sun"
        case 4:
            imageName = "cloud.rain"
        default:
            imageName = ""
        }
        
        return Image(systemName: imageName)
    }
    
    var photoView: some View {
        ZStack {
            BackgroundColor(color: note.backgroundColor)

            VStack {
                Text(note.title)
                    .font(.title)
                    .foregroundColor(note.fontColor)
                
                HStack {
                    Text(note.date.formatted())
                        .font(.caption)
                        .foregroundColor(note.fontColor)
                    
                    getWeatherImage(weather: note.weather)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(note.fontColor)
                }

                Text(note.content)
                    .foregroundColor(note.fontColor)

                if !note.images.isEmpty {
                    LazyVGrid(columns: columnGrid[getGridIdx()], spacing: 5) {
                        ForEach(note.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }
            .padding()
        }.preferredColorScheme(.light)
    }

    var body: some View {
        ZStack {
            photoView

            Button {
                self.saveAlert = true
            } label: {
                HStack {
                   Image(systemName: "square.and.arrow.down.fill")
                       .font(.system(size: 20))

                   Text("Save")
                       .font(.headline)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(.green)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.horizontal)
            }
            .alert("Save to Photo?", isPresented: $saveAlert) {
                Button("Cancel", role: .cancel) { }
                .foregroundColor(.gray)

                Button("Save") {
                    let saver = ImageSaver()
                    saver.writeToPhotoAlbum(image: photoView.snapshot())
                }
                .foregroundColor(.accentColor)
            }
            .offset(y: UIScreen.main.bounds.height * 0.35)
        }
    }
}

struct Note {
    var title: String
    var date: Date
    var weather: Int
    var content: String
    var fontColor: Color
    var backgroundColor: Color
    var images: [UIImage]
    
    static let defaultNote = Note(title: "", date: Date.now, weather: 0, content: "", fontColor: .black, backgroundColor: .gray, images: [UIImage]())
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view?.bounds = UIScreen.main.bounds
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        NoteView()
    }
}
