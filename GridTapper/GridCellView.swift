//
//  GridCellView.swift
//  GridTapper
//
//  Created by Peter Thomas on 4/27/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

class GridCellView: UIView {

    private var innerView:UIView!
    private static let gridBorderInset:CGFloat = 5
    
    private var leftConstraint:NSLayoutConstraint!
    private var rightConstraint:NSLayoutConstraint!
    private var topConstraint:NSLayoutConstraint!
    private var bottomConstraint:NSLayoutConstraint!
    
    private var childViews = [GridCellView]()
    
    public var shadowOpacity:Float = 0.5 {
        didSet {
            innerView.layer.shadowOpacity = shadowOpacity
        }
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.backgroundColor = UIColor.white//UIColor(red:CGFloat(drand48()), green:CGFloat(drand48()), blue:CGFloat(drand48()), alpha:1.0)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        innerView = UIView()
        innerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(innerView)
        
        leftConstraint = innerView.leftAnchor.constraint(equalTo: leftAnchor, constant:0)
        rightConstraint = innerView.rightAnchor.constraint(equalTo: rightAnchor, constant:0)
        topConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant:0)
        bottomConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant:0)
        
        [leftConstraint, rightConstraint, topConstraint, bottomConstraint].forEach { $0?.isActive = true }
        
        innerView.layer.cornerRadius = 2
        innerView.layer.shadowColor = UIColor.black.cgColor
        innerView.layer.shadowOffset = CGSize(width:0, height:1)
        innerView.layer.shadowRadius = 1
        innerView.layer.shadowOpacity = shadowOpacity
    }
    
    var highlightType:Int? = nil {
        didSet {
            if let highlightType = highlightType {
                if highlightType == 0 {
                    innerView.backgroundColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
                } else if highlightType == 1 {
                    innerView.backgroundColor = UIColor.darkGray
                }
            } else {
                innerView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            }
        }
    }
    
    var isHighlighted:Bool { return highlightType != nil }
    
    func merge() {
        
        childViews.forEach { $0.needsUpdateConstraints() }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveLinear], animations: {
            self.childViews.enumerated().forEach {
                $0.element.mergedFrame(forIndex: $0.offset)
            }
        }) { (completed) in
            self.childViews.forEach { $0.removeFromSuperview() }
            self.childViews.removeAll()
            self.innerView.layer.shadowOpacity = self.shadowOpacity
        }
    }
    
    func split(into childCells:[GridCell]?) {
        
        guard let childCells = childCells else { return }

        var childViews = [GridCellView]()
        for (index, child) in childCells.enumerated() {
            let childView = GridCellView.createGridCellView(child, atIndex: index)
            childViews.append(childView)
        }
        
        addChildViews(childViews)
        
        self.innerView.layer.shadowOpacity = 0.0

        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState, .curveLinear], animations: {
            childCells.enumerated().forEach { $0.element.cellView?.splitFrame(forIndex: $0.offset) }
        })
    }
    
    static func createGridCellView(_ child:GridCell, atIndex index:Int) -> GridCellView {
        
        let childView = GridCellView(frame: CGRect.zero)
        childView.mergedFrame(forIndex:index)
        childView.highlightType = child.highlightType
        
        child.cellView = childView
        
        return childView
    }
    
    func mergedFrame(forIndex index:Int) {
        
        leftConstraint.constant = 0
        rightConstraint.constant = 0
        topConstraint.constant = 0
        bottomConstraint.constant = 0
        layoutIfNeeded()
    }
    
    func splitFrame(forIndex index:Int) {
        let offset = [(0, -1, 0, -1), (1, 0, 0, -1), (0, -1, 1, 0), (1, 0, 1, 0)][index]
        leftConstraint.constant = GridCellView.gridBorderInset * CGFloat(offset.0)
        rightConstraint.constant = GridCellView.gridBorderInset * CGFloat(offset.1)
        topConstraint.constant = GridCellView.gridBorderInset * CGFloat(offset.2)
        bottomConstraint.constant = GridCellView.gridBorderInset * CGFloat(offset.3)
        layoutIfNeeded()
    }
    
    func addChildViews(_ childViews:[GridCellView]) {
        
        self.childViews.forEach { $0.removeFromSuperview() }
        self.childViews.append(contentsOf: childViews)
        
        childViews.forEach { innerView.addSubview($0) }
        
        childViews[0].leftAnchor.constraint(equalTo: innerView.leftAnchor).isActive = true
        childViews[0].rightAnchor.constraint(equalTo: childViews[1].leftAnchor).isActive = true
        childViews[0].topAnchor.constraint(equalTo: innerView.topAnchor).isActive = true
        childViews[0].bottomAnchor.constraint(equalTo: childViews[2].topAnchor).isActive = true

        childViews[1].rightAnchor.constraint(equalTo: innerView.rightAnchor).isActive = true
        childViews[1].topAnchor.constraint(equalTo: innerView.topAnchor).isActive = true
        childViews[1].bottomAnchor.constraint(equalTo: childViews[3].topAnchor).isActive = true

        childViews[2].leftAnchor.constraint(equalTo: innerView.leftAnchor).isActive = true
        childViews[2].rightAnchor.constraint(equalTo: childViews[3].leftAnchor).isActive = true
        childViews[2].bottomAnchor.constraint(equalTo: innerView.bottomAnchor).isActive = true

        childViews[3].rightAnchor.constraint(equalTo: innerView.rightAnchor).isActive = true
        childViews[3].bottomAnchor.constraint(equalTo: innerView.bottomAnchor).isActive = true
        
        childViews[0].widthAnchor.constraint(equalTo: childViews[1].widthAnchor).isActive = true
        childViews[0].heightAnchor.constraint(equalTo: childViews[1].heightAnchor).isActive = true
        childViews[0].widthAnchor.constraint(equalTo: childViews[2].widthAnchor).isActive = true
        childViews[0].heightAnchor.constraint(equalTo: childViews[2].heightAnchor).isActive = true
        childViews[0].widthAnchor.constraint(equalTo: childViews[3].widthAnchor).isActive = true
        childViews[0].heightAnchor.constraint(equalTo: childViews[3].heightAnchor).isActive = true
        
        childViews.enumerated().forEach {
            $0.element.mergedFrame(forIndex: $0.offset)
        }
    }    
}
