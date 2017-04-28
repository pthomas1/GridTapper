//
//  TouchReceivingView.swift
//  GridTapper
//
//  Created by Peter Thomas on 4/27/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

protocol TouchReceivingViewDelegate:class {
    func touchBegan(touch:UITouch)
}

class TouchReceivingView: UIView {

    weak var delegate:TouchReceivingViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            delegate?.touchBegan(touch: touch)
        }
    }
}
