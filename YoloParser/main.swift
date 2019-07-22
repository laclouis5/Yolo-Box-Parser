//
//  main.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

// TODO: Transform the app in a Mac application
let basePath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
let pathGT = basePath.appendingPathComponent("ground-truth")
let pathDet = basePath.appendingPathComponent("detection-results")
do {
    var boxes = try parseYoloFolder(pathGT)
    boxes += try parseYoloFolder(pathDet)    
    boxes.dispStats()
    
    let evaluator = PascalVOCMetrics()
    evaluator.evaluate(on: boxes)
    
    evaluator.detail.forEach { (eval) in
        print(eval)
    }
    
} catch YoloParserError.folderNotListable(let folderURL){
    print("Folder not readable: \(folderURL)")
}
