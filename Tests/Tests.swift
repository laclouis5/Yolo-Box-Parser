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

class YoloParserTests: XCTestCase {
    
    func testReadFile() {
        let basePath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        let path = basePath.appendingPathComponent("ground-truth").appendingPathComponent("im_726.txt")
        let parser = Parser()
        
        let refboxes = [
            Box(name: path.lastPathComponent, a: 1596, b: 438, c: 1817, d: 1370, label: "maize", coordType: .XYX2Y2),
            Box(name: path.lastPathComponent, a: 2000, b: 663, c: 2449, d: 896, label: "maize", coordType: .XYX2Y2),
            Box(name: path.lastPathComponent, a: 1622, b: 800, c: 1758, d: 934, label: "maize_stem", coordType: .XYX2Y2),
            Box(name: path.lastPathComponent, a: 2186, b: 723, c: 2341, d: 881, label: "maize_stem", coordType: .XYX2Y2)
        ]
        
        do {
            let boxes = try parser.parseYoloTxtFile(path, coordType: .XYX2Y2, coordSystem: .absolute)
            
            XCTAssert(Set(boxes) == Set(refboxes))
            
        } catch {
            XCTAssert(false)
        }
    }
}
