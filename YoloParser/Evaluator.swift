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
        for label in boxes.labels {
            let gts = boxes.getBoundingBoxesByLabel(label).getBoundingBoxesByDetectionMode(.groundTruth).getBoxesDictByName()
            var dets = boxes.getBoundingBoxesByLabel(label).getBoundingBoxesByDetectionMode(.detection)
            
            dets.sort { (boxA, boxB) -> Bool in
                boxB.confidence! < boxA.confidence!
            }
            
            var truePositiveNumber = 0
            var evaluation = Evaluation(reserveCapacity: dets.count)
            evaluation.label = label
            evaluation.totalPositive = boxes.getBoundingBoxesByLabel(label).getBoundingBoxesByDetectionMode(.groundTruth).count
            
            // Counter
            var counter = gts.mapValues { (bbxs) -> [Bool] in
                return [Bool](repeating: false, count: bbxs.count)
            }
            
            for detection in dets {
                let imageGts = gts[detection.name] ?? []
                var maxIoU = 0.0
                var index = 0
                
                for (i, gt) in imageGts.enumerated() {
                    let iou = detection.computeIoU(with: gt)
                    // Find the greatest IoU
                    if iou > maxIoU {
                        maxIoU = iou
                        index = i
                    }
                }
                
                let visited = counter[detection.name]?[index] ?? true
                
                if maxIoU >= iouTresh && !visited {
                    evaluation.truePositives.append(true)
                    counter[detection.name]![index] = true
                    truePositiveNumber += 1
                    
                    let falsePositiveNumber = evaluation.truePositives.count - truePositiveNumber
                    
                    let (precision, recall) = computePrecRec(tp: truePositiveNumber, fp: falsePositiveNumber, totalPositive: evaluation.totalPositive)
                    
                    evaluation.recalls.append(recall)
                    evaluation.precisions.append(precision)
                    
                } else {
                    evaluation.truePositives.append(false)
                }
            }
            
            detail.append(evaluation)
        }
    }
    
    private func computePrecRec(tp: Int, fp: Int, totalPositive: Int) -> (Double, Double) {
        let precision = Double(tp) / (Double(tp) + Double(fp))
        let recall = Double(tp) / Double(totalPositive)
        
        return (precision, recall)
    }
}
