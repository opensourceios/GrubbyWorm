//
//  Tip.swift
//  GrubbyWorm
//
//  Created by Wayne on 15/10/5.
//  Copyright © 2015年 GAME-CHINA.ORG. All rights reserved.
//

import SpriteKit

class Tip: SKNode {
    
    private var _board: SKSpriteNode!
    private var _label: SKLabelNode!
    
    var text: String {
        didSet {
            renderTip()
        }
    }
    
    var fontColor: SKColor {
        didSet {
            _label.fontColor = fontColor
        }
    }
    
    var fontSize: CGFloat {
        didSet {
            _label.fontSize = fontSize
        }
    }
    
    init(text: String) {
        self.text = text
        self.fontColor = SKColor.whiteColor()
        self.fontSize = 14
        
        super.init()
        
        _board = SKSpriteNode(imageNamed: "tip")
        _board.centerRect = CGRectMake(10/100, 10/100, 80/100, 80/100)
        _board.color = Theme.mood_bar_up_color
        
        // "San Francisco"
        _label = SKLabelNode(fontNamed: "San Francisco")
        _label.text = text
        _label.fontSize = 14
        _label.verticalAlignmentMode = .Center
        _label.horizontalAlignmentMode = .Center
        
        _board.addChild(_label)
        
        self.addChild(_board)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderTip() {
        _label.text = text
        
        let size = _label.frame.size
        _board.size = CGSizeMake(size.width + 12, size.height + 6)
    }
}
