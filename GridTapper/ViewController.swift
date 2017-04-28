//
//  ViewController.swift
//  GridTapper
//
//  Created by Peter Thomas on 4/26/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var gameState:GameState = GameState()
    
    var displaylink:CADisplayLink!
    
    @IBOutlet weak var gridView: GridCellView!
    
    var touchReceivingView:TouchReceivingView { return view as! TouchReceivingView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchReceivingView.delegate = self
        gameState.delegate = self
        
        if displaylink == nil {
            displaylink = CADisplayLink(target: self, selector: #selector(stepDisplayLinkTimer(_:)))
            displaylink.add(to: .current, forMode: .defaultRunLoopMode)
        }
        
        var childViews = [GridCellView]()
        gameState.visitAllCells { (child, index) in
            let childView = GridCellView.createGridCellView(child, atIndex:index)
            childViews.append(childView)
        }
        
        gridView.addChildViews(childViews)
        childViews.enumerated().forEach {
            $0.element.splitFrame(forIndex: $0.offset)
        }
        gridView.shadowOpacity = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameState.isPaused = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameState.isPaused = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stepDisplayLinkTimer(_ displayLink:CADisplayLink) {
        
        gameState.tick(deltaTimeInterval: 1.0/60.0)
    }
}

extension ViewController: TouchReceivingViewDelegate {
    
    func touchBegan(touch:UITouch) {
        
        var nearestTouchedCell:GridCell?
        var nearestTouchedDistance = CGFloat.infinity
        
        gameState.visitAllCells { (child, index) in
            
            guard child.isHighlighted else { return }
            guard let childView = child.cellView, child.childCells == nil else { return }
            
            let touchLocation = touch.location(in: childView)
            if childView.bounds.contains(touchLocation) {
                nearestTouchedCell = child
                nearestTouchedDistance = 0
            } else {
                let center = CGPoint(x:childView.bounds.origin.x + childView.bounds.size.width / 2,
                                     y:childView.bounds.origin.y + childView.bounds.size.height / 2)
                
                let delta = CGPoint(x:center.x - touchLocation.x,
                                    y:center.y - touchLocation.y)
                
                let distance = sqrt(delta.x * delta.x + delta.y * delta.y)
                if distance < 35 {
                    if nearestTouchedCell == nil || distance < nearestTouchedDistance {
                        nearestTouchedCell = child
                        nearestTouchedDistance = distance
                    }
                }
            }
        }
        
        guard let touchedCell = nearestTouchedCell else { return }
        if nearestTouchedDistance > 0 {
            logger.debug("nearestTouchedDistance: \(nearestTouchedDistance)")
        }
        gameState.cellWasTouched(touchedCell)
    }
}

extension ViewController: GameStateDelegateProtocol {
    
    func gameState(_ gameState:GameState, didSplitCell cell:GridCell) {

        guard let cellView = cell.cellView else { return }
        cellView.split(into: cell.childCells)
    }
    
    func gameState(_ gameState:GameState, willMergeCell cell:GridCell, isMergeRoot:Bool) {

        guard let cellView = cell.cellView else { return }
        cellView.merge()
    }
    
    func gameState(_ gameState:GameState, didHighlightCell cell:GridCell) {

        guard let cellView = cell.cellView else { return }
        UIView.animate(withDuration: 0.2) {
            cellView.highlightType = cell.highlightType
        }
    }

    func gameState(_ gameState:GameState, didDehighlightCell cell:GridCell) {

        guard let cellView = cell.cellView else { return }
        UIView.animate(withDuration: 0.2) {
            cellView.highlightType = nil
        }
    }
}
