//
//  EditScheduleView.swift
//  85Dollars
//
//  Created by George Birch on 2/11/25.
//

import SwiftUI

struct EditScheduleView: View {
    
    @StateObject var viewModel: EditScheduleViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section("Weekdays") {
                    RotationSelectionView(viewModel: WeekdaySelectionViewModel())
                }
                Section("Weeks of Month") {
                    RotationSelectionView(viewModel: MonthweekSelectionViewModel())
                }
                Section("Alarms") {
                    ForEach(viewModel.alarmViewModels) { alarmVM in
                        AlarmPickerView(viewModel: alarmVM)
                    }
                    Button(action: viewModel.newAlarmButtonTapped) {
                        HStack {
                            Text("Add new alarm")
                            Spacer()
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .listStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        viewModel.cancelButtonTapped()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.doneButtonTapped()
                    }
                }
            }
        }
    }
}

#Preview {
    EditScheduleView(viewModel: EditScheduleViewModel())
}
