//
//  Tests_macOS.swift
//  Tests macOS
//
//  Created by Matthew Malaker on 2/2/22.
//

import XCTest
import SwiftUI

class Tests_macOS: XCTestCase {
    @ObservedObject var bessel = Bessel_Function()
    
    func testBesselJ1(){
        let x = 1.0
        let testValue = (sin(x)/pow(x,2))-(cos(x)/x)
        let functionValue = bessel.besselJ1(x: x)
        XCTAssertEqual(testValue, functionValue, accuracy: 1.0e-7, "BesselJ1 Accuracy Failure.")
    }
    
    func testBesselJ0(){
        let x = 1.0
        let testValue = sin(x)/x
        let functionValue = bessel.besselJ0(x: x)
        XCTAssertEqual(testValue, functionValue, accuracy: 1.0e-7, "BesselJ0 Accuracy Failure.")
    }
    
    func testNeumannN1(){
        let x = 1.0
        let testValue = (-1*cos(x)/pow(x,2))-(sin(x)/x)
        let functionValue = bessel.neumannN1(x: x)
        XCTAssertEqual(testValue, functionValue, accuracy: 1.0e-7, "NeumannN1 Accuracy Failure.")
        
    }
    func testNeumannN0(){
        let x = 1.0
        let testValue = -1*cos(x)/x
        let functionValue = bessel.neumannN0(x: x)
        XCTAssertEqual(testValue, functionValue, accuracy: 1.0e-7, "NeumannN1 Accuracy Failure.")
        
    }
    
    func testBesselJLPlusOne(){
        l=1
        let x = 1.0
        let testValue = ((((2*Double(l))+1)/x)*(Jl)-JlMinusOne)
        let functionValue = bessel.BesselJLPlusOne(l: 1, x: x, Jl: bessel.besselJ1(x: x), JlMinusOne: bessel.besselJ0(x: x))
        XCTAssertEqual(testValue, functionValue, accuracy: 1.0e-7, "BesselJ+1 Accuracy Failure.")
        
    }
    
    func testBesselBesselJLMinusOne(){
        let x = 1.0
        let testValue = (((((2*Double(l))+1)/x)*Jl)-JlPlusOne)
        let functionValue = bessel.BesselJMinusOne(l: 1, x: x, Jl: bessel.besselJ1(x: x), JlPlusOne: bessel.BesselJLPlusOne(l: 1, x: x, Jl: bessel.besselJ1(x: x), JlMinusOne: bessel.besselJ0(x: x)))
        XCTAssertEqual(testValue, functionValue, accuracy: 1.0e-7, "BesselJ-1 Accuracy Failure.")
    }
    
    func testBesselJUpwardRecursion(){
        
    }
    
    func testBesselJDownwardRecursion(){
        
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
