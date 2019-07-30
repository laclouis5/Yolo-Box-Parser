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
        var labs = [String]()
        for box in self {
            labs.append(box.label)
        }
        return Set(labs).sorted()
    }
    
    var imageNames: [String] {
        var names = [String]()
        for box in self {
            names.append(box.name)
        }
         return Set(names).sorted()
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
    func getBoundingBoxesByLabel(_ label: String) -> [Box] {
        return self.filter { $0.label == label }
    }
    
    func getBoundingBoxesByDetectionMode(_ detectionMode: Box.DetectionMode) -> [Box] {
        return self.filter { $0.detectionMode == detectionMode }
    }
    
    func getBoundingBoxesByName(_ name: String) -> [Box] {
        return self.filter { $0.name == name }
    }
    
    func getBoxesDictByName() -> [String: [Box]] {
        return self.reduce(into: [String:[Box]](), { (result, box) in
            if result[box.name] != nil {
                result[box.name]!.append(box)
            } else {
                result[box.name] = [box]
            }
        })
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
