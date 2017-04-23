//
//  DateFormatTests.swift
//  TechEmpathy
//
//  Created by Sarah Olson on 4/23/17.
//  Copyright © 2017 SarahEOlson. All rights reserved.
//

import XCTest

class DateFormatTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFormatToString() {
        
        let dateString = "2015-10-22 07:45:17 +0000"
        let firebaseDate = Date.firebaseDate(fromString: dateString)
        
        var components = DateComponents()
        components.hour = 7
        components.minute = 45
        components.second = 17
        components.year = 2015
        components.day = 22
        components.month = 10
        components.timeZone = TimeZone(abbreviation: "GMT")
        
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "GMT")!
        
        let calendarDate = cal.date(from: components)!
        
        print("Calendar date: \(calendarDate)")
        
        XCTAssert(firebaseDate == calendarDate, "Date strings do not match: calendarDate: \(calendarDate), firebaseDate: \(String(describing: firebaseDate))")
    }
    
    func testFirebaseString() {
        let dateString = "2017-04-17 14:45:09 +0000"
        let firebaseDate = Date.firebaseDate(fromString: dateString)
        
        var components = DateComponents()
        components.hour = 14
        components.minute = 45
        components.second = 09
        components.year = 2017
        components.day = 17
        components.month = 4
        components.timeZone = TimeZone(abbreviation: "GMT")
        
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "GMT")!
        
        let calendarDate = cal.date(from: components)!
        
        print("Calendar date: \(calendarDate)")
        
        XCTAssert(firebaseDate == calendarDate, "Date strings do not match: calendarDate: \(calendarDate), firebaseDate: \(String(describing: firebaseDate))")
    }
    
}
