//
//  YoloParser.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation
import AppKit

enum YoloParserError: Error {
    case folderNotListable(_ folder: URL)
    case unreadableAnnotation(_ file: URL)
    case unreadableImage(_ image: URL)
    case invalidLineFormat(file: URL, line: [String])
    case boxObjectNotInitializable(file: URL, line: [String])
}

func parseYoloTxtFile(_ fileURL: URL) throws -> [Box] {
    var boxes = [Box]()
    
    guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
        throw YoloParserError.unreadableAnnotation(fileURL)
    }
    
    let imageURL = fileURL.deletingPathExtension().appendingPathExtension("jpg")
    // FIXME: NSImage uses too much space whith large images
    guard let imgSize = NSImage(contentsOf: imageURL)?.size else {
        throw YoloParserError.unreadableImage(imageURL)
    }
    
    for line in content.split(separator: "\n") {
        let line = line.split(separator: " ")
 
        let label = String(line[0])
        
        if line.count == 5 {
            guard let x = Double(line[1]), let y = Double(line[2]), let w = Double(line[3]), let h = Double(line[4]) else {
                
                throw YoloParserError.invalidLineFormat(file: fileURL, line: line.map { String($0) })
            }
            guard let box = Box(name: fileURL.lastPathComponent, a: x, b: y, c: w, d: h, label: label, coordType: .XYWH, coordSystem: .relative, imgSize: NSSize(width: imgSize.width, height: imgSize.height), detectionMode: .groundTruth) else {
                
                throw YoloParserError.boxObjectNotInitializable(file: fileURL, line: line.map { String($0) })
            }
            
            boxes.append(box)
            
        } else if line.count == 6 {
            guard let confidence = Double(line[1]), let x = Double(line[2]), let y = Double(line[3]), let w = Double(line[4]), let h = Double(line[5]) else {
                
                throw YoloParserError.invalidLineFormat(file: fileURL, line: line.map { String($0) })
            }
            
            guard let box = Box(name: fileURL.lastPathComponent, a: x, b: y, c: w, d: h, label: label, coordType: .XYWH, coordSystem: .relative, imgSize: NSSize(width: imgSize.width, height: imgSize.height), detectionMode: .detection, confidence: confidence) else {
                
                throw YoloParserError.boxObjectNotInitializable(file: fileURL, line: line.map { String($0) })
            }
            
            boxes.append(box)
            
        } else {
            throw YoloParserError.invalidLineFormat(file: fileURL, line: line.map { String($0) })
        }
    
    }
    
    return boxes
}

func parseYoloFolder(_ folder: URL) throws -> [Box] {
    var boxes = [Box]()
    
    let fileManager = FileManager.default
    guard var files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
        throw YoloParserError.folderNotListable(folder)
    }
    
    files = files.filter { $0.pathExtension == "txt" }
    
    for file in files {
        do {
            boxes.append(contentsOf: try parseYoloTxtFile(file))
            
        } catch YoloParserError.unreadableAnnotation(let fileURL) {
            print("Unable to read annotation file: \(fileURL)")
        } catch YoloParserError.unreadableImage(let imageURL) {
            print("Unable to read image file: \(imageURL)")
        } catch YoloParserError.invalidLineFormat(let fileURL, let line) {
            print("Invalid line format: \(line) for file: \(fileURL)")
        } catch YoloParserError.boxObjectNotInitializable(let fileURL, let line) {
            print("Unable to create a Box object for line: \(line) of file: \(fileURL)")
        }
    }
    
    return boxes
}
