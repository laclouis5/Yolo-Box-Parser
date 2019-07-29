//
//  Evaluator.swift
//  YoloParser
//
//  Created by Louis Lac on 19/07/2019.
//  Copyright © 2019 Louis Lac. All rights reserved.
//

import Foundation

class Evaluator {

    struct Evaluation: CustomStringConvertible {
        // We now in advance the size of this structure, memory could be reserved instead of appening items for each detection
        // Also it seems sub-optimal to compute true/false positive number with filtering
        var label = ""
        var mAP = 0.0
        var truePositives = [Bool]()
        var totalPositive = 0
        var precisions = [Double]()
        var recalls = [Double]()
        
        var description: String {
            var description = "\(label.uppercased())\n"
            description += "  Total Positive: \(totalPositive)\n"
            description += "  True Positive:  \(truePositives.filter { $0 }.count)\n"
            description += "  False Positive: \(truePositives.count - truePositives.filter { $0 }.count)\n"
            return description
        }
        
        init() { }
        
        init(reserveCapacity count: Int) {
            truePositives.reserveCapacity(count)
            precisions.reserveCapacity(count)
            recalls.reserveCapacity(count)
        }
    }
    
    //MARK: - Properties
    var result = Evaluation()
    var detail = [Evaluation]()
    
    //MARK: - Methods
    func evaluate(on boxes: [Box], iouTresh: Double = 0.5) {
        // Loop through each class
        for label in boxes.labels {
            var truePositiveNumber = 0
            
            // Retreive all detections and ground truth for this class
            let detectionBoxes = boxes.getBoundingBoxesByDetectionMode(.detection).getBoundingBoxesByLabel(label)
            
            let groundTruthBoxes = boxes.getBoundingBoxesByDetectionMode(.groundTruth).getBoundingBoxesByLabel(label)
            
            // Update evaluation result
            var evaluation = Evaluation(reserveCapacity: detectionBoxes.count)
            evaluation.label = label
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
                    var maxIoU = 0.0
                    
                    // Loop through image GT
                    for (i, groundTruth) in groundTruth.enumerated() {
                        let iou = detection.computeIoU(with: groundTruth)
                        // Find the greatest IoU
                        if iou > maxIoU {
                            maxIoU = iou
                            index = i
                        }
                    }
                        
                    if maxIoU >= iouTresh && !visited[index] {
                        evaluation.truePositives.append(true)
                        visited[index] = true
                        truePositiveNumber += 1
                        
                        let falsePositiveNumber = evaluation.truePositives.count - truePositiveNumber
        
                        let (precision, recall) = computePrecRec(tp: truePositiveNumber, fp: falsePositiveNumber, totalPositive: evaluation.totalPositive)
                        
                        evaluation.recalls.append(recall)
                        evaluation.precisions.append(precision)
                        
                    } else {
                        evaluation.truePositives.append(false)
                    }
                }
            }
            detail.append(evaluation)
        }
    }
    
    func test(on boxes: [Box]) {
        for label in boxes.labels {
            let gts = boxes.getBoundingBoxesByLabel(label).getBoundingBoxesByDetectionMode(.groundTruth).getBoundingBoxesByNameV2()
            var dets = boxes.getBoundingBoxesByLabel(label).getBoundingBoxesByDetectionMode(.detection)
            
            dets.sort { (boxA, boxB) -> Bool in
                boxB.confidence! < boxA.confidence!
            }
            
            var truePositiveNumber = 0
            var evaluation = Evaluation(reserveCapacity: dets.count)
            evaluation.label = label
            evaluation.totalPositive = gts.count
            
            // Counter
            let counter = gts.mapValues { (bbxs) -> [Bool] in
                return [Bool](repeating: false, count: bbxs.count)
            }
            
            for detection in dets {
                
            }
            
        }
    }
    
    private func computePrecRec(tp: Int, fp: Int, totalPositive: Int) -> (Double, Double) {
        let precision = Double(tp) / (Double(tp) + Double(fp))
        let recall = Double(tp) / Double(totalPositive)
        
        return (precision, recall)
    }
}
