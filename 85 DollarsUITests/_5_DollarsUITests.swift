//
//  _5_DollarsUITests.swift
//  85 DollarsUITests
//
//  Created by George Birch on 5/31/23.
//

import XCTest

final class _5_DollarsUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testCreateSchedule() {
        app.launch()
        app.navigationBars["_5_Dollars.ScheduleListView"].buttons["Add"].tap()
        
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Set rotation"]/*[[".cells.staticTexts[\"Set rotation\"]",".staticTexts[\"Set rotation\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tables.staticTexts["1st"].tap()
        app.tables.staticTexts["3rd"].tap()
        app.navigationBars["Create cleaning schedule"].buttons["Done"].tap()
        
        app.tables.staticTexts["Add weekdays"].tap()
        app.tables.staticTexts["Wednesday"].tap()
        app.navigationBars["Create cleaning schedule"].buttons["Done"].tap()
        
        app.tables.staticTexts["Add alarm"].tap()
        let datePickersQuery = app.datePickers
        datePickersQuery.pickerWheels["5 o’clock"].swipeDown()
        datePickersQuery.pickerWheels["00 minutes"].swipeUp()
        app.buttons["1 day before cleaning"].tap()
        app.descendants(matching: .any).element(matching: .any, identifier: "2 days before cleaning").tap()
        app.navigationBars["_5_Dollars.AlarmDetailView"].buttons["Done"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 5)
        app.navigationBars["Create cleaning schedule"].buttons["Done"].tap()
        XCTAssertEqual(app.tables.cells.count, 2)
    }
    
    func testToggleSchedule() {
        app.launch()
        XCTAssertEqual(app.switches.element.value as? String, "1")
        app.switches.element.tap()
        XCTAssertEqual(app.switches.element.value as? String, "0")
        app.switches.element.tap()
        XCTAssertEqual(app.switches.element.value as? String, "1")
    }
    
    func testEditSchedule() {
        app.launch()
        XCTAssertEqual(app.switches.element.value as? String, "1")
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["more"]/*[[".cells.buttons[\"more\"]",".buttons[\"more\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Edit"]/*[[".cells.buttons[\"Edit\"]",".buttons[\"Edit\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertEqual(app.tables.cells.count, 5)
        tablesQuery.staticTexts["1st of the month"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Every week"]/*[[".cells.staticTexts[\"Every week\"]",".staticTexts[\"Every week\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let doneButton = app.navigationBars["Edit cleaning schedule"].buttons["Done"]
        doneButton.tap()
        doneButton.tap()
        XCTAssertEqual(app.tables.cells.count, 1)
        XCTAssertEqual(app.switches.element.value as? String, "1")
    }
    
    func testDeleteSchedule() {
        app.launch()
        XCTAssertEqual(app.tables.cells.count, 1)
        app.buttons["more"].tap()
        app.collectionViews.buttons["Delete Schedule"].tap()
        XCTAssertEqual(app.tables.cells.count, 0)
    }
    
}
