//
//  GridCell.swift
//  GridTapper
//
//  Created by Peter Thomas on 4/26/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

class GridCell: NSObject {

    static let maxDepth:Int = 2
    
    let depth:Int
    var parentCell:GridCell?
    var childCells:[GridCell]?
    
    var timeRemaining:TimeInterval = TimeInterval.infinity
    
    var highlightType:Int?
    var isHighlighted:Bool { return highlightType != nil }
    
    weak var cellView:GridCellView?
    var canSplit:Bool { return depth < GridCell.maxDepth }
    
    var isAncestorHighlighted:Bool {
        var ancestor:GridCell? = self
        
        while ancestor != nil && ancestor!.isHighlighted == false {
            ancestor = ancestor?.parentCell
        }
        return ancestor?.isHighlighted == true
    }
    
    init(parent:GridCell?) {
        self.parentCell = parent
        var depth = 0
        var ancestor = parent
        while ancestor != nil {
            depth += 1
            ancestor = ancestor?.parentCell
        }
        self.depth = depth
    }

    func tick(deltaTimeInterval:TimeInterval) -> Bool {

        guard timeRemaining > 0 else { return false }
        
        timeRemaining -= deltaTimeInterval
        return timeRemaining <= 0
    }
    
    func split() {
        timeRemaining = TimeInterval.infinity
        
        var newChildCells = [GridCell]()        
        for _ in 0..<4 {
            newChildCells.append(GridCell(parent:self))
        }
        
        childCells = newChildCells
    }
    
    func merge() {
        timeRemaining = TimeInterval.infinity
        childCells = nil
    }
}
