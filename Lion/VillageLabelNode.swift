//
//  VillageLabelNode.swift
//  Lion
//
//  Created by Thomas Brichart on 05/07/2015.
//  Copyright (c) 2015 Thomas Brichart. All rights reserved.
//

import SpriteKit

class VillageLabelNode: SKSpriteNode {
    var nameNode: SKLabelNode!
    var valueNode: SKLabelNode!
    
    var barNode: SKSpriteNode!
    var barAction: SKAction!
    var barUpAction: SKAction!
    
    var villageValue: CGFloat!
    
    init(frame: CGRect, name: String, value: CGFloat) {
        super.init(texture: nil, color: NSColor.clearColor(), size: frame.size)
        
        self.position = frame.origin
        self.zPosition = 10
        
        villageValue = value
        
        if nameNode?.parent == nil {
            nameNode = SKLabelNode(fontNamed: font)
            nameNode.position.x = 80
            nameNode.horizontalAlignmentMode = .Left
            nameNode.text = name
            nameNode.fontColor = villageNameColor
            nameNode.fontSize = 14
            self.addChild(nameNode)
        }
        
        if valueNode?.parent == nil {
            valueNode = SKLabelNode(fontNamed: font)
            valueNode.position = CGPointZero
            valueNode.position.x = self.size.width - 100
            valueNode.horizontalAlignmentMode = .Right
            valueNode.text = "0"
            valueNode.fontColor = villageValueColor
            valueNode.fontSize = 14
            self.addChild(valueNode)
        }
        
        let numMax = villageValuesList.reduce(0, combine: {max($0, $1)})
        
        if barNode?.parent == nil {
            barNode = SKSpriteNode(color: smallBarsColor, size: CGSizeMake(0, frame.size.height))
            barNode.alpha = 0.4
            barNode.position.x = self.size.width - 100
            barNode.anchorPoint = CGPointMake(1, 0)
            self.addChild(barNode)
        }
        
        barAction = SKAction.resizeToWidth(0, duration: goingDownTime)
        barUpAction = SKAction.resizeToWidth((self.size.width-180)*(villageValue/numMax), duration: barTimeUp * Double(villageValue/numMax))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
