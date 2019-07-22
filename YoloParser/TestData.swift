//
//  TestData.swift
//  YoloParser
//
//  Created by Louis Lac on 21/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

class TestData {
    var data: [Box]
    
    init() {
        data = [Box]()
        data.append(Box(name: "im_1.jpg", a: 0, b: 0, c: 10, d: 10, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, imgSize: NSSize(width: 200, height: 100), detectionMode: .detection, confidence: 0.9)!)
        data.append(Box(name: "im_1.jpg", a: 0, b: 0, c: 10, d: 10, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, imgSize: NSSize(width: 200, height: 100), detectionMode: .detection, confidence: 0.8)!)
        
        data.append(Box(name: "im_1.jpg", a: 0, b: 0, c: 10, d: 10, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, imgSize: NSSize(width: 200, height: 200), detectionMode: .groundTruth, confidence: nil)!)
        data.append(Box(name: "im_1.jpg", a: 10, b: 10, c: 20, d: 20, label: "maize", coordType: .XYX2Y2, coordSystem: .absolute, imgSize: NSSize(width: 200, height: 200), detectionMode: .groundTruth, confidence: nil)!)    }
}
