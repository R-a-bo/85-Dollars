//
//  AlarmPickerView.swift
//  85Dollars
//
//  Created by George Birch on 2/10/25.
//

import SwiftUI

struct AlarmPickerView: View {
    
    @StateObject var viewModel: AlarmPickerViewModel
    
    var body: some View {
        HStack {
            Picker(selection: $viewModel.selectedDay) {
                ForEach(viewModel.dayOptions, id: \.self) { dayOption in
                    Text(dayOption).tag(viewModel.dayOptions.firstIndex(of: dayOption) ?? -1)
                }
            } label: {}
            .pickerStyle(.menu)
            Spacer()
            DatePicker(selection: $viewModel.time, displayedComponents: [.hourAndMinute]) {}
                .pickerStyle(.wheel)
        }
    }
}

#Preview {
    AlarmPickerView(viewModel: AlarmPickerViewModel())
}
