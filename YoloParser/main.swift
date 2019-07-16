//
//  main.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

// MARK: Main
let basePath = URL(fileURLWithPath: "/Users/louislac/Documents/Etudes/PhD/Projet BIPBIP/darknet/data/val")

do {
    let boxes = try parseYoloFolder(basePath)
    boxes.forEach { print($0) }
} catch YoloParserError.folderNotListable(let folderURL){
    print("Folder not listable: \(folderURL)")
}

let imageURL: URL = basePath.appendingPathComponent("im_600.jpg")
