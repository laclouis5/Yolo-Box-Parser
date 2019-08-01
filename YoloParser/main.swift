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
    let parser = Parser()
    let evaluator = Evaluator()
    var boxes = try parser.parseYoloFolder(pathGT)
    boxes += try parser.parseYoloFolder(pathDet)
//    let boxes = TestData().data
    boxes.dispStats()
    
    evaluator.evaluate(on: boxes)
    evaluator.dispStats()
    
    print(evaluator.detail["maize"]!.precisions)
    print(evaluator.detail["maize"]!.recalls)
    
} catch YoloParserError.folderNotListable(let folderURL) {
    print("Folder not readable: \(folderURL)")
}
