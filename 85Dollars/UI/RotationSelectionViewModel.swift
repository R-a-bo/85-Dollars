//
//  RotationPickerViewModel.swift
//  85Dollars
//
//  Created by George Birch on 2/10/25.
//

import SwiftUI

protocol RotationSelectionViewModel: ObservableObject {
    var elements: [RotationSelectionElement] { get }
    func didTapElement(_ id: Int)
}

class RotationSelectionViewModelStub: RotationSelectionViewModel {
    
    @Published var elements: [RotationSelectionElement]
    
    init() {
        let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        var elements = daysOfWeek.enumerated().map {
            RotationSelectionElement(id: $0.0, text: $0.1, isSelected: false)
        }
        elements[1].isSelected = true
        self.elements = elements
    }
    
    func didTapElement(_ id: Int) {
        elements[id].isSelected.toggle()
    }
}
