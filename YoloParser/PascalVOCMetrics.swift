//
//  Evaluator.swift
//  YoloParser
//
//  Created by Louis Lac on 19/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

class PascalVOCMetrics {
    //MARK: - Properties
    struct Evaluation: CustomStringConvertible {
        var label = ""
        var mAP = 0.0
        var truePositive = [Bool]()
        var totalPositive = 0
        var precision = [Double]()
        var recall = [Double]()
        
        var description: String {
            var description = "Label: \(label)\n"
            description += "  Total Positive: \(totalPositive)\n"
            description += "  True Positive:  \(truePositive.filter { $0 }.count)\n"
            description += "  False Positive: \(truePositive.count - truePositive.filter { $0 }.count)\n"
            return description
        }
    }
    
    var result = Evaluation()
    var detail = [Evaluation]()
    
    //MARK: - Methods
    func evaluate(on boxes: [Box], IoUThreshold: Double) {
        // Loop through each class
        for label in boxes.labels {
            var evaluation = Evaluation()
            evaluation.label = label
            
            // Retreive all detections and ground truth for this class
            let detectionBoxes = boxes.getBoundingBoxesByDetectionMode(.detection).getBoundingBoxesByLabel(label)
            let groundTruthBoxes = boxes.getBoundingBoxesByDetectionMode(.groundTruth).getBoundingBoxesByLabel(label)
            
            // Update evaluation result
            evaluation.totalPositive = groundTruthBoxes.count
            
            // Loop through images
            for image in detectionBoxes.imageNames {
                var detections = detectionBoxes.getBoundingBoxesByName(image)
                let groundTruth = groundTruthBoxes.getBoundingBoxesByName(image)
                
                // Sort detections by decreasing confidence
                detections.sort { (boxA, boxB) -> Bool in
                    boxB.confidence! < boxA.confidence!
                }
                
                var visited = [Bool](repeating: false, count: groundTruth.count)
                var index = 0
                
                // Loop through image detections
                for detection in detections {
                    var maxIoU = Double.leastNonzeroMagnitude
                    
                    // Loop through image GT
                    for (i, groundTruth) in groundTruth.enumerated() {
                        let iou = detection.computeIoU(with: groundTruth)
                        // Find the greatest IoU
                        if iou > maxIoU {
                            maxIoU = iou
                            index = i
                        }
                    }
                        
                    if maxIoU >= IoUThreshold && !visited[index] {
                        evaluation.truePositive.append(true)
                        visited[index] = true
                        
                        let truePositiveNumber = Double(evaluation.truePositive.filter { $0 }.count)
                        let falsePositiveNumber = Double(evaluation.truePositive.filter { !$0 }.count)
                        
                        evaluation.recall.append(truePositiveNumber / Double(evaluation.totalPositive))
                        evaluation.precision.append(truePositiveNumber / (truePositiveNumber + falsePositiveNumber))
                        
                    } else {
                        evaluation.truePositive.append(false)
                    }
                }
            }
            detail.append(evaluation)
        }
    }
}
