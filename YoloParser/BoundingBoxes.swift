//
//  BoundingBoxes.swift
//  YoloParser
//
//  Created by Louis Lac on 15/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

extension MutableCollection where Element == Box {
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
        // FIXME: Make this function tyo accept all kind of dict
        self = self.map {
            // Boxes are always stored as absolute XYWH
            Box(name: $0.name,
                a: $0.x, b: $0.y, c: $0.w, d: $0.h,
                label: labels[$0.label] ?? "Unknown",
                coordType: .XYWH,
                coordSystem: .absolute,
                imgSize: $0.imgSize,
                detectionMode: $0.detectionMode)!
        } as! Self
    }
}
