//
//  PhotoEditView.swift
//  PhotoPoof
//
//  Created by FanRende on 2021/12/2.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct PhotoEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var image: UIImage
    @State var editingImage: CIImage?
    @State var outputImage: CIImage?
    @StateObject var filters = ImageFiltersViewModel()
    @Namespace private var animation
    
    @State var showFilters = true
    @State var saveAlert = false

    @State var saturation: Double = 1
    @State var brightness: Double = 0
    @State var contrast  : Double = 1
    
    func getUIImage() -> UIImage? {
        let context = CIContext()

        guard let outputImage = self.outputImage,
              let resultImage = context.createCGImage(outputImage, from: outputImage.extent)
        else {return nil}

        return UIImage(cgImage: resultImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    func updateOutputImage() {
        if let editingImage = editingImage {
            let tmp = CIFilter(name: "CIColorControls")
            
            tmp?.setValue(editingImage, forKey: kCIInputImageKey)
            tmp?.setValue(saturation, forKey: kCIInputSaturationKey)
            tmp?.setValue(brightness, forKey: kCIInputBrightnessKey)
            tmp?.setValue(contrast  , forKey: kCIInputContrastKey)
            
            if let outputImage = tmp?.outputImage {
                self.outputImage = filters.generateImage(outputImage)
            }
        }
    }
    
    func getUpperView() -> some View {
        Group {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
                .onAppear {
                    self.editingImage = CIImage(image: image)

                    updateOutputImage()
                }
                .matchedGeometryEffect(id: "originImage", in: animation)

            Image(systemName: showFilters ? "arrow.right": "arrow.down")
                .matchedGeometryEffect(id: "arrow", in: animation)

            if let resultImage = getUIImage() {
                Image(uiImage: resultImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .matchedGeometryEffect(id: "previewImage", in: animation)
            }
        }
    }

    var body: some View {
        VStack {
            if showFilters {
                HStack {
                    getUpperView()
                }
                .frame(height: UIScreen.main.bounds.height * 0.3)
            }
            else {
                VStack {
                    getUpperView()
                }
                .frame(height: UIScreen.main.bounds.height * 0.7)
            }
            
            Toggle(isOn: $showFilters) {
                Text("Show Filters")
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: showFilters)

            List {
                Section {
                    VStack {
                        Text("Saturation")
                        Slider(value: $saturation, in: 0...2, step: 0.1)
                    }
                    .swipeToDo {
                        saturation = 1
                    }

                    VStack {
                        Text("Brightness")
                        Slider(value: $brightness, in: -1...1, step: 0.1)
                    }
                    .swipeToDo {
                        brightness = 0
                    }

                    VStack {
                        Text("Contrast")
                        Slider(value: $contrast, in: 0...2, step: 0.1)
                    }
                    .swipeToDo {
                        contrast = 1
                    }
                }
                .onChange(of: saturation) { _ in
                    updateOutputImage()
                }
                .onChange(of: brightness) { _ in
                    updateOutputImage()
                }
                .onChange(of: contrast) { _ in
                    updateOutputImage()
                }
                .contextMenu {
                    Button {
                        saturation = 1
                        brightness = 0
                        contrast = 1
                    } label: {
                        Label {
                            Text("Reset")
                        } icon: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
                
                
                filters.filtersForm()
                    .onChange(of: filters.models) { _ in
                        updateOutputImage()
                    }

                Button {
                    print("Add Filter")
                    filters.addNewFilter(image: image)
                } label: {
                    Label {
                        Text("Add Filter")
                    } icon: {
                        Image(systemName: "plus.square.fill")
                    }
                    .foregroundColor(.green)
                }
                
                if filters.models.isEmpty {
                    Button {
                        filters.addRandomFilters(image: image)
                    } label: {
                        Label {
                            Text("Random Effect")
                        } icon: {
                            Image(systemName: "dice.fill")
                        }
                        .foregroundColor(.accentColor)
                    }
                }
                else {
                    Button {
                        filters.removeAllFilters()
                    } label: {
                        Label {
                            Text("Remove All Filters")
                        } icon: {
                            Image(systemName: "trash.fill")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Button {
                    saveAlert = true
                } label: {
                    Label {
                        Text("Export")
                    } icon: {
                        Image(systemName: "square.and.arrow.up.fill")
                    }
                    .foregroundColor(.accentColor)
                }
                .alert("Save to Photo?", isPresented: $saveAlert) {
                    Button("Cancel", role: .cancel) { }
                    .foregroundColor(.gray)

                    Button("Save") {
                        if let resultImage = getUIImage() {
                            let saver = ImageSaver()
                            saver.writeToPhotoAlbum(image: resultImage)
                        }
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .opacity(showFilters ? 1: 0)
            .animation(.spring(), value: filters.models)
            .animation(.easeInOut, value: showFilters)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: showFilters)
    }
}

extension View {
    func hasScrollEnabled(_ value: Bool) -> some View {
        self.onAppear {
            UITableView.appearance().isScrollEnabled = value
        }
    }
    
    func swipeToDo(_ f: @escaping () -> Void) -> some View {
        self.swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                withAnimation {
                    f()
                }
            } label: {
                Label {
                    Text("Reset")
                } icon: {
                    Image(systemName: "arrow.counterclockwise")
                }
            }.tint(.green)
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }
}

struct FilterModel: Identifiable, Hashable {
    var filterType: Int
    // 0.None 1.sepiaTone 2.pixellate 3.crystallize 4.twirlDistortion
    var arg0: Double
    var arg1: Double
    var arg2: Double
    
    var imageWidth: Double
    var imageHeight: Double
    
    let id = UUID()
}

extension FilterModel {
    static let empty = FilterModel(filterType: 0, arg0: 0, arg1: 0, arg2: 0, imageWidth: 0, imageHeight: 0)
}

class ImageFiltersViewModel: ObservableObject {
    @Published var models = [FilterModel]()
    
    init() {
    }
    
    func addNewFilter(image: UIImage) -> Void {
        models.append(
            FilterModel(filterType: 0, arg0: 1, arg1: image.size.width / 2, arg2: image.size.height / 2, imageWidth: image.size.width, imageHeight: image.size.height)
        )
    }
    
    func addRandomFilters(image: UIImage) -> Void {
        let quantity = Int.random(in: 1...5)
        
        for _ in 0...quantity {
            let type = Int.random(in: 1...4)

            let minValue: Double = type == 1 ? 0: 1
            let maxValue: Double = type == 1 ? 1: max(image.size.width, image.size.height) / 16

            var arg0 = Double.random(in: minValue...maxValue)
            let arg1 = Double.random(in: 0...image.size.width)
            let arg2 = Double.random(in: 0...image.size.height)
            
            if type == 4 {
                arg0 = (arg0 / 4 + maxValue / 4 * 3) * 4
            }

            models.append(
                FilterModel(filterType: type, arg0: arg0, arg1: arg1, arg2: arg2, imageWidth: image.size.width, imageHeight: image.size.height)
            )
        }
    }
    
    func removeAllFilters() -> Void {
        self.models.removeAll()
    }
    
    func filtersForm() -> some View {
        ForEach(models) { modelCopy in
            let idx = self.models.firstIndex { model in
                model.id == modelCopy.id
            }!
            let model = Binding<FilterModel> {
                self.models[safe: idx] ?? FilterModel.empty
            } set: { value in
                self.models[idx] = value
            }

            Section {
                Picker(selection: model.filterType) {
                    Text("(無)").tag(0)
                    Text("SepiaTone").tag(1)
                    Text("Pixellate").tag(2)
                    Text("Crystallize").tag(3)
                    Text("TwirlDistortion").tag(4)
                } label: {
                    Text("Filter")
                }

                self.innerForm(model)

                Button {
                    self.models.remove(at: idx)
                } label: {
                    Label {
                        Text("Delete")
                    } icon: {
                        Image(systemName: "minus.square.fill")
                    }
                    .foregroundColor(.red)
                }
            }
            .hasScrollEnabled(false)
        }
    }

    @ViewBuilder
    func innerForm(_ model: Binding<FilterModel>) -> some View {
        let type = model.filterType.wrappedValue

        switch type {
        case 1:
            AnyView(sepiaToneForm(model))
        case 2:
            AnyView(pixellateForm(model))
        case 3:
            AnyView(crystallizeForm(model))
        case 4:
            AnyView(twirlDistortionForm(model))
        default:
            EmptyView()
        }
    }
    
    // 0.None 1.sepiaTone 2.pixellate 3.crystallize 4.twirlDistortion
    
    @ViewBuilder
    func sepiaToneForm(_ model: Binding<FilterModel>) -> some View {
        HStack {
            Text("Intensity")
            Slider(value: model.arg0, in: 0...1) {
                
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1")
            }
        }
    }
    
    @ViewBuilder
    func pixellateForm(_ model: Binding<FilterModel>) -> some View {
        let maxValue = max(model.imageWidth.wrappedValue, model.imageHeight.wrappedValue) / 2

        HStack {
            Text("Scale")
            Slider(value: model.arg0, in: 1...maxValue) {
                
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text(String(maxValue))
            }
        }
    }
    
    @ViewBuilder
    func crystallizeForm(_ model: Binding<FilterModel>) -> some View {
        let maxValue = max(model.imageWidth.wrappedValue, model.imageHeight.wrappedValue) / 2

        HStack {
            Text("Radius")
            Slider(value: model.arg0, in: 1...maxValue) {
                
            } minimumValueLabel: {
                Text("1")
            } maximumValueLabel: {
                Text(String(maxValue))
            }
        }
    }
    
    @ViewBuilder
    func twirlDistortionForm(_ model: Binding<FilterModel>) -> some View {
        let maxValue = max(model.imageWidth.wrappedValue, model.imageHeight.wrappedValue) / 2

        VStack {
            HStack {
                Text("Radius")
                Slider(value: model.arg0, in: 1...maxValue) {
                    
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text(String(maxValue))
                }
            }
            
            Text("Center")
            
            HStack {
                Text("X")
                Slider(value: model.arg1, in: 0...model.imageWidth.wrappedValue) {
                    
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text(String(model.imageWidth.wrappedValue))
                }
            }
            
            HStack {
                Text("Y")
                Slider(value: model.arg2, in: 0...model.imageHeight.wrappedValue) {
                    
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text(String(model.imageHeight.wrappedValue))
                }
            }
        }
    }
    
    func generateImage(_ image: CIImage) -> CIImage {
        var ret = image
        
        for model in models {
            switch model.filterType {
            case 1:
                let tmp = CIFilter.sepiaTone()
                tmp.inputImage = ret
                tmp.intensity = Float(model.arg0)
                
                guard let outputImage = tmp.outputImage else {continue}
                ret = outputImage
                
                break
            case 2:
                let tmp = CIFilter.pixellate()
                tmp.inputImage = ret
                tmp.scale = Float(model.arg0)
                
                guard let outputImage = tmp.outputImage else {continue}
                ret = outputImage
                
                break
            case 3:
                let tmp = CIFilter.crystallize()
                tmp.inputImage = ret
                tmp.radius = Float(model.arg0)
                
                guard let outputImage = tmp.outputImage else {continue}
                ret = outputImage
                
                break
            case 4:
                let tmp = CIFilter.twirlDistortion()
                tmp.inputImage = ret
                tmp.radius = Float(model.arg0)
                tmp.center = CGPoint(x: model.arg1, y: model.arg2)
                
                guard let outputImage = tmp.outputImage else {continue}
                ret = outputImage
                
                break
            default:
                break
            }
        }
        
        return ret
    }
}

struct PhotoEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhotoEditView(image: UIImage(systemName: "car.2.fill")!)
        }
//        .preferredColorScheme(.dark)
    }
}
