//
//  main.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

let basePath = URL(fileURLWithPath: "/Users/louislac/Documents/Etudes/PhD/Projet BIPBIP/darknet/data/val")

do {
    var boxes = try parseYoloFolder(basePath)
    print(boxes[0])
    boxes.mapLabels(with: ["0": "maize", "1": "bean", "2": "carrot"])
    print(boxes[0])
} catch YoloParserError.folderNotListable(let folderURL){
    print("Folder not readable: \(folderURL)")
}

let imageURL: URL = basePath.appendingPathComponent("im_600.jpg")
