//
//  EditScheduleViewModel.swift
//  85Dollars
//
//  Created by George Birch on 2/11/25.
//

import SwiftUI

protocol EditScheduleViewModelDelegate: AnyObject {
    func editScheduleViewModelDismiss(_ editScheduleViewModel: EditScheduleViewModel)
}

class EditScheduleViewModel: ObservableObject {
    
    @Published var weekdaySelectionViewModel: WeekdaySelectionViewModel
    @Published var monthweekSelectionViewModel: MonthweekSelectionViewModel
    @Published var alarmViewModels: [AlarmPickerViewModel]
    @Published var alertMessage: (String, String)? // title, message
    
    weak var delegate: EditScheduleViewModelDelegate?
    
    private let scheduleRepository: ScheduleRepository
    private let scheduleId: UUID
    
    init(schedule: Schedule? = nil, scheduleRepository: ScheduleRepository) {
        self.weekdaySelectionViewModel = WeekdaySelectionViewModel()
        self.monthweekSelectionViewModel = MonthweekSelectionViewModel()
        self.alarmViewModels = [AlarmPickerViewModel()]
        self.scheduleRepository = scheduleRepository
        self.scheduleId = schedule?.id ?? UUID()
    }
    
    // MARK: - view actions
    
    func doneButtonTapped() {
        let weekdays = weekdaySelectionViewModel.toWeekdays()
        let monthweeks = monthweekSelectionViewModel.toMonthweeks()
        let alarms = alarmViewModels.map { $0.toAlarm() }
        let schedule = Schedule(id: scheduleId,
                                weekdays: weekdays,
                                monthweeks: monthweeks,
                                alarms: alarms)
        do {
            try scheduleRepository.saveSchedule(schedule)
            delegate?.editScheduleViewModelDismiss(self)
        } catch {
            alertMessage = ("Something went wrong", "")
        }
    }
    
    func cancelButtonTapped() {
        delegate?.editScheduleViewModelDismiss(self)
    }
    
    func newAlarmButtonTapped() {
        alarmViewModels.append(AlarmPickerViewModel())
    }
}

class EditScheduleViewModelStub: EditScheduleViewModel {
    
    init() {
        let schedule = Schedule(id: UUID(), weekdays: [.friday], monthweeks: [.third], alarms: [Alarm(time: DateComponents(hour: 3, minute: 3), daysBeforeCleaning: 2, id: UUID())])
        super.init(schedule: schedule, scheduleRepository: ScheduleRepositoryStub())
        self.alertMessage = ("Something went wrong", "")
    }
    
}
