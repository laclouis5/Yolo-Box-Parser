//
//  BoundingBoxes.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension Collection where Element == Box {
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
    // TODO: add an optional delegate to print things during process
    
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
}
