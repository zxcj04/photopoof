//
//  MVVMExample.swift
//  PhotoPoof
//
//  Created by FanRende on 2021/12/5.
//

import SwiftUI

struct testView: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        Picker(selection: $viewModel.model.a) {
            Text("1").tag(1)
        } label: {
            Text("A")
        }
    }
}

struct Model {
    var a: Int
}

class ViewModel: ObservableObject {
    @Published var model: Model = Model(a: 1)
    
    func getA() -> Int {
        return model.a
    }
    
    func setA(a: Int) {
        model.a = a
    }
}
