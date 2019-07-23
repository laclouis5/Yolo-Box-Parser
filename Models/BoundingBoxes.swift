//
//  BoundingBoxes.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Array where Element == Box {
    
    // MARK: - Computed Properties
    var labels: [String] {
        var labels = [String]()
        for box in self {
            let label = box.label
            if !labels.contains(label) {
                labels.append(label)
            }
        }
        return labels.sorted()
    }
    
    var imageNames: [String] {
        var imageNames = [String]()
        for box in self {
            let imageName = box.name
            if !imageNames.contains(imageName) {
                imageNames.append(imageName)
            }
        }
        return imageNames.sorted()
    }
    
    func dispStats() {
        let gtBoxes = self.getBoundingBoxesByDetectionMode(.groundTruth)
        let detBoxes = self.getBoundingBoxesByDetectionMode(.detection)
        
        var description = ""
        description += "Ground Truth Count: \(gtBoxes.count)\n"
        description += "Detection Count:    \(detBoxes.count)\n"
        description += "Number of labels:   \(gtBoxes.labels.count)\n"
        
        for label in gtBoxes.labels {
            let labelBoxes = gtBoxes.getBoundingBoxesByLabel(label)
            
            description += "\(label.uppercased())\n"
            description += "  Images:      \(labelBoxes.imageNames.count)\n"
            description += "  Annotations: \(labelBoxes.count)\n"
        }
        
        print(description)
    }
    
    // MARK: - Methods
    func getBoundingBoxesByLabel(_ labels: String...) -> [Box] {
        return self.filter { labels.contains($0.label) }
    }
    
    func getBoundingBoxesByLabel(_ labels: [String]) -> [Box] {
        return self.filter { labels.contains($0.label) }
    }
    
    func getBoundingBoxesByDetectionMode(_ detectionMode: Box.DetectionMode) -> [Box] {
        return self.filter { $0.detectionMode == detectionMode }
    }
    
    func getBoundingBoxesByName(_ names: String...) -> [Box] {
        return self.filter { names.contains($0.name) }
    }
    
    func getBoundingBoxesByName(_ names: [String]) -> [Box] {
        return self.filter { names.contains($0.name) }
    }
    
    mutating func mapLabels(with labels: [String: String]) {
        // FIXME: Make this function to accept all kind of dict, not only String
        guard Set(labels.keys) == Set(self.labels) else {
            print("Error: new label keys must match old labels")
            return
        }
            
        self = self.map {
            // Boxes are always stored as absolute XYWH
            Box(name: $0.name,
                a: $0.x, b: $0.y, c: $0.w, d: $0.h,
                label: labels[$0.label]!,
                coordType: .XYWH,
                coordSystem: .absolute,
                confidence: $0.confidence,
                imgSize: $0.imgSize)
        }
    }
}
