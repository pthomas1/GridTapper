//
//  GameState.swift
//  GridTapper
//
//  Created by Peter Thomas on 4/26/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

protocol GameStateDelegateProtocol:class {
    
    func gameState(_ gameState:GameState, didSplitCell:GridCell)
    func gameState(_ gameState:GameState, willMergeCell:GridCell, isMergeRoot:Bool)
    func gameState(_ gameState:GameState, didHighlightCell:GridCell)
    func gameState(_ gameState:GameState, didDehighlightCell:GridCell)
}

class GameState: NSObject {

    let launchProbability:Double = 1.0 / 960.0
    var isPaused:Bool = true
    
    weak var delegate:GameStateDelegateProtocol?
    
    var childCells = [GridCell]()
    
    var negativeHighlightType = 1
    
    override init() {
        
        super.init()
        
        childCells.append(GridCell(parent:nil))
        childCells.append(GridCell(parent:nil))
        childCells.append(GridCell(parent:nil))
        childCells.append(GridCell(parent:nil))
    }
    
    func cellWasTouched(_ cell:GridCell) {

        guard cell.isHighlighted else { return }

        if cell.highlightType == negativeHighlightType {
            guard let parent = cell.parentCell else { return }
            mergeCell(parent)
        } else {
            if cell.canSplit {
                splitCell(cell)
            } else {
                cell.highlightType = nil
                delegate?.gameState(self, didDehighlightCell: cell)
            }
        }
    }
    
    func tick(deltaTimeInterval:TimeInterval) {
        
        if isPaused == false {
        
//            timeUntilNextPulse -= deltaTimeInterval
//            if timeUntilNextPulse <= 0 {
                scheduleHighlights()
//                timeUntilNextPulse = meter
//            }

            manageHighlightTimeouts(deltaTimeInterval:deltaTimeInterval)
        }
    }

    func scheduleHighlights() {
        
        var cells = [GridCell]()
        visitAllCells { (child, _) in
            cells.append(child)
        }
        
        let selectableCells = cells.filter { $0.isAncestorHighlighted == false && $0.childCells == nil }
        for cell in selectableCells {
            guard selectableCells.count > 0 else { return }
            
            let logScore = log(Double(1 + selectableCells.count))
            if drand48() < logScore * launchProbability {
                cell.highlightType = Int(drand48() * 2.0)
                
                cell.timeRemaining = 1.8
                delegate?.gameState(self, didHighlightCell: cell)
            }
        }
    }
    
    func manageHighlightTimeouts(deltaTimeInterval:TimeInterval) {
        
        visitAllCells { (child, _) in
            
            let timerExpired = child.tick(deltaTimeInterval:deltaTimeInterval)
            if timerExpired {
                
                if child.isHighlighted {
                    
                    if child.highlightType == negativeHighlightType {
                        child.highlightType = nil
                        delegate?.gameState(self, didDehighlightCell: child)
                    } else {
                        if let parent = child.parentCell {
                            mergeCell(parent)
                        } else {
                            logger.error("Game over")
                        }
                    }
                }
            }
        }

    }
    
    func splitCell(_ cell:GridCell) {

        cell.highlightType = nil
        delegate?.gameState(self, didDehighlightCell: cell)

        cell.split()
        delegate?.gameState(self, didSplitCell:cell)
    }
    
    func mergeCell(_ cell:GridCell, isMergeRoot:Bool=true) {
        
        cell.highlightType = nil
        delegate?.gameState(self, didDehighlightCell: cell)
        
        for child in cell.childCells ?? [] {
            mergeCell(child, isMergeRoot: false)
        }
        
        delegate?.gameState(self, willMergeCell: cell, isMergeRoot:isMergeRoot)
        cell.merge()
    }
    
    func randomCell() -> GridCell {
        var allCells = [GridCell]()
        visitAllCells { (child, _) in
            allCells.append(child)
        }
        
        let randomIndex = Int(drand48() * Double(allCells.count))
        return allCells[randomIndex]
    }
    
    func visitCells(parent:GridCell?, children:[GridCell], visit: (_ child:GridCell, _ index:Int) -> Void ) {
        
        for (index, child) in children.enumerated() {
            visit(child, index)
            
            guard let grandchildren = child.childCells else { continue }
            visitCells(parent:child, children:grandchildren, visit:visit)
        }
    }
    
    func visitAllCells(visit: (_ child:GridCell, _ index:Int) -> Void ) {
        visitCells(parent:nil, children:childCells, visit:visit)
    }
}
