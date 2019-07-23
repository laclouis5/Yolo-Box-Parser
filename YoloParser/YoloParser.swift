//
//  YoloParser.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

enum YoloParserError: Error {
    case folderNotListable(_ folder: URL)
    case unreadableAnnotation(_ file: URL)
    case unreadableImage(_ image: URL) // Obsolete
    case invalidLineFormat(file: URL, line: [String])
}

struct Parser {
    
    func parseYoloTxtFile(_ fileURL: URL, coordType: Box.CoordType = .XYX2Y2, coordSystem: Box.CoordinateSystem = .absolute) throws -> [Box] {
        var boxes = [Box]()
        
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            throw YoloParserError.unreadableAnnotation(fileURL)
        }
        
        for line in content.split(separator: "\n") {
            let line = line.split(separator: " ")
            let label = String(line[0])
            
            // Case Ground Truth
            if line.count == 5 {
                guard let x = Double(line[1]), let y = Double(line[2]), let w = Double(line[3]), let h = Double(line[4]) else {
                    throw YoloParserError.invalidLineFormat(file: fileURL, line: line.map { String($0) })
                }
            
                boxes.append(Box(name: fileURL.lastPathComponent, a: x, b: y, c: w, d: h, label: label, coordType: coordType, coordSystem: coordSystem))
                
            // Case Detection
            } else if line.count == 6 {
                guard let confidence = Double(line[1]), let x = Double(line[2]), let y = Double(line[3]), let w = Double(line[4]), let h = Double(line[5]) else {
                    throw YoloParserError.invalidLineFormat(file: fileURL, line: line.map { String($0) })
                }
                
                boxes.append(Box(name: fileURL.lastPathComponent, a: x, b: y, c: w, d: h, label: label, coordType: coordType, coordSystem: coordSystem, confidence: confidence))
            
            } else {
                throw YoloParserError.invalidLineFormat(file: fileURL, line: line.map { String($0) })
            }
        }
        
        return boxes
    }

    func parseYoloFolder(_ folder: URL, coordType: Box.CoordType = .XYX2Y2, coordSystem: Box.CoordinateSystem = .absolute) throws -> [Box] {
        var boxes = [Box]()
        let fileManager = FileManager.default
        
        guard var files = try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) else {
            throw YoloParserError.folderNotListable(folder)
        }
        
        files = files.filter { $0.pathExtension == "txt" }
        
        for file in files {
            do {
                boxes.append(contentsOf: try parseYoloTxtFile(file, coordType: coordType, coordSystem: coordSystem))
            } catch YoloParserError.unreadableAnnotation(let fileURL) {
                print("Unable to read annotation file: \(fileURL)")
            } catch YoloParserError.invalidLineFormat(let fileURL, let line) {
                print("Invalid line format: \(line) for file: \(fileURL)")
            }
        }
        
        return boxes
    }
}
