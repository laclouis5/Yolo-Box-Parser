//
//  Tests.swift
//  Tests
//
//  Created by Louis Lac on 22/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import XCTest
@testable import YoloParser

class BoxesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIoU() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let refBox = Box(name: "test", a: 5, b: 5, c: 10, d: 10, label: "test")
        
        let boxes = [
            Box(name: "test", a: 5, b: 5, c: 10, d: 10, label: "test"), // 1
            Box(name: "test", a: 15, b: 15, c: 10, d: 10, label: "test"), // 0
            Box(name: "test", a: 0, b: 0, c: 0, d: 0, label: "test"), // 0
        ]
        
        let values = [1.0, 0, 0]
        
        for (i, box) in boxes.enumerated() {
            let iou = refBox.computeIoU(with: box)
            XCTAssert(iou == values[i], "Value was \(iou) instead of \(values[i])")
        }
    }
    
    func testDetectionMode() {
        let detetionBox = Box(name: "test", a: 0, b: 0, c: 0, d: 0, label: "test", confidence: 1)
        let gtBox = Box(name: "test", a: 0, b: 0, c: 0, d: 0, label: "test")
        
        XCTAssert(detetionBox.detectionMode == .detection)
        XCTAssert(gtBox.detectionMode == .groundTruth)
    }
    
    func testCoordType() {
        let box1 = Box(name: "test", a: 0, b: 0, c: 10, d: 10, label: "test", coordType: .XYX2Y2, coordSystem: .relative)
        let box2 = Box(name: "test", a: 5, b: 5, c: 10, d: 10, label: "test", coordType: .XYWH, coordSystem: .relative)
        
        XCTAssert(box1.x == 5 && box1.y == 5 && box1.w == 10 && box1.h == 10)
        XCTAssert(box2.x == 5 && box2.y == 5 && box2.w == 10 && box2.h == 10)
    }
}
