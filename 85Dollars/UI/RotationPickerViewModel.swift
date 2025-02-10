//
//  RotationPickerViewModel.swift
//  85Dollars
//
//  Created by George Birch on 2/10/25.
//

import SwiftUI

protocol RotationPickerViewModel: ObservableObject {
    var elements: [RotationPickerElement] { get }
    func didTapElement(_ id: Int)
}

class RotationPickerViewModelStub: RotationPickerViewModel {
    
    @Published var elements: [RotationPickerElement]
    
    init() {
        let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        var elements = daysOfWeek.enumerated().map {
            RotationPickerElement(id: $0.0, text: $0.1, isSelected: false)
        }
        elements[1].isSelected = true
        self.elements = elements
    }
    
    func didTapElement(_ id: Int) {
        elements[id].isSelected.toggle()
    }
}
