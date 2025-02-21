//
//  EditScheduleView.swift
//  85Dollars
//
//  Created by George Birch on 2/11/25.
//

import SwiftUI

struct EditScheduleView: View {
    
    @StateObject var viewModel: EditScheduleViewModel
    private var showAlert: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: {
                guard !$0 else { return }
                viewModel.alertMessage = nil
            }
        )
    }
    
    var body: some View {
        List {
            Section("Weekdays") {
                RotationSelectionView(viewModel: viewModel.weekdaySelectionViewModel)
            }
            Section("Weeks of Month") {
                RotationSelectionView(viewModel: viewModel.monthweekSelectionViewModel)
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
        .alert(viewModel.alertMessage?.0 ?? "", isPresented: showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage?.1 ?? "")
        }
    }
}

#Preview {
    NavigationStack {
        EditScheduleView(viewModel: EditScheduleViewModelStub())
    }
}
