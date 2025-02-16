//
//  RotationPickerView.swift
//  85Dollars
//
//  Created by George Birch on 2/10/25.
//

import SwiftUI

struct RotationSelectionElement: Identifiable {
    var id: Int
    var text: String
    var isSelected: Bool
}

struct RotationSelectionView: View {
    
    @StateObject var viewModel: RotationSelectionViewModel
    
    // TODO: pretty up buttons
    var body: some View {
        HStack(spacing: 1) {
            Spacer()
            ForEach(viewModel.elements) { element in
                Button {
                    viewModel.didTapElement(element.id)
                } label: {
                    Text(element.text)
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                }
                .background(element.isSelected ? .blue : .gray)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 0))
            }
            Spacer()
        }
    }
}

#Preview {
    RotationSelectionView(viewModel: MonthweekSelectionViewModel())
}
