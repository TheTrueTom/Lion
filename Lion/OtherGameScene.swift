//
//  OtherGameScene.swift
//  Lion
//
//  Created by Thomas Brichart on 05/07/2015.
//  Copyright (c) 2015 Thomas Brichart. All rights reserved.
//

import SpriteKit

let villageNameList:[String] = ["Hans et Sophie Sholl",
    "Lucie Aubrac",
    "Stéphane Hessel",
    "Jacques-Yves Cousteau",
    "Édith Stein",
    "Alexandra David Néel",
    "Théodore Monod",
    "Frère Roger",
    "Jane Goodall",
    "Albert Londres",
    "G. de Gaulle-Anthonioz",
    "Alcide de Gasperi",
    "Konrad Adenauer",
    "Jacques Delors",
    "Simone Veil",
    "Gro Harlem-Brundtland",
    "Antoine de Saint-Exupéry",
    "Robert Schumann",
    "Albert Schweizer",
    "Robert Badinter",
    "Pierre Gaspard",
    "Paul-Émile Victor",
    "Klara Zetkin",
    "Elsa Triolet",
    "Anne Frank"]

var villageValuesList: [CGFloat] = [CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100)),
    CGFloat(arc4random_uniform(100))]

/// Percentage that should be reached after all bars have gone down
var grandTotalPercent: CGFloat = 62.9

/// Time for one bar to go down
var goingDownTime: Double = 3

/// Time for the max bar to go up
var barTimeUp: Double = 10

/// Color of the current village label
var currentVillageColor: NSColor = NSColor.blackColor()

/// Color of the percentage of the right gauge
var rightGaugeColor: NSColor = NSColor.greenColor()

/// Color of the small bars
var smallBarsColor: NSColor = NSColor.greenColor()

/// Color of the village name
var villageNameColor: NSColor = NSColor.blackColor()

/// Color of the village value
var villageValueColor: NSColor = NSColor.blackColor()

class OtherGameScene: SKScene {
    
    var world: SKNode!
    var labelList: SKNode!
    
    var rightLevelNode: SKSpriteNode!
    var rightLevelLabel: SKLabelNode!
    var rightLevelBlinking: SKAction!
    var rightLevel: CGFloat = 0
    var rightLevelIsBlinking = false
    
    var energySaveLabel: SKLabelNode!
    var energySaveBlinking: SKAction!
    
    var input: String = ""
    
    var villageLabels: [VillageLabelNode] = []
    
    var villageInAction: VillageLabelNode?
    
    var shouldStop = false
    
    var upVillages: Int = 0
    
    var currentVillageLabel: SKLabelNode!
    
    var mask: SKSpriteNode!
    var background: SKSpriteNode!
    
    /** Initial location for window dragging set on mouseDown*/
    var initialLocation: NSPoint!
    
    override func didMoveToView(view: SKView) {
        
        if world?.parent == nil {
            world = SKNode()
            self.addChild(world)
        }
        
        if labelList?.parent == nil {
            labelList = SKNode()
            world.addChild(labelList)
        }
        
        setupSkin()
        setupLevels()
        setupLabels()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        var windowFrame = self.view!.window!.frame
        
        initialLocation = NSEvent.mouseLocation()
        
        initialLocation.x -= windowFrame.origin.x
        initialLocation.y -= windowFrame.origin.y
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        var screenFrame = NSScreen.mainScreen()!.frame
        var windowFrame = self.view!.window!.frame
        
        var currentLocation = NSEvent.mouseLocation()
        
        var newOrigin: NSPoint = NSPoint(x: 0, y: 0)
        
        newOrigin.x = currentLocation.x - initialLocation.x
        newOrigin.y = currentLocation.y - initialLocation.y
        
        self.view!.window!.setFrameOrigin(newOrigin)
    }
    
    override func keyDown(theEvent: NSEvent) {
        
        if let character = theEvent.characters {
            switch character {
            case "p":
                changeLevelValueBy(0.1)
            case "m":
                changeLevelValueBy(-0.1)
            case "=":
                changeLevelValueTo(0)
            case "x", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                input += character
            case "a":
                shouldStop = false
                emptyNextVillage()
            case "z":
                shouldStop = true
                emptyNextVillage()
            case "s":
                shouldStop = true
            case "w":
                fillVillages()
            case " ":
                speed = (speed == 0) ? 1 : 0
            case "b":
                switchBlinking()
            case "c":
                clearVillages()
            default:
                break
            }
        }
    }
    
    func switchBlinking() {
        rightLevelIsBlinking = !rightLevelIsBlinking
        
        if rightLevelIsBlinking {
            rightLevelNode.runAction(rightLevelBlinking, withKey: "blinking_right")
            energySaveLabel.runAction(energySaveBlinking, withKey: "blinking_label")
        } else {
            rightLevelNode.removeActionForKey("blinking_right")
            energySaveLabel.removeActionForKey("blinking_label")
            rightLevelNode.color = rightGaugeColor
            energySaveLabel.alpha = 0
        }
    }
    
    func fillVillages() {
        
        for village in villageLabels {
            village.barNode.runAction(village.barUpAction) {
                upVillages++
            }
        }
    }
    
    func emptyNextVillage() {
        
        var sum = villageValuesList.reduce(0, combine: +)
        
        for village in villageLabels {
            if village.villageValue != 0 {
                
                villageInAction = village
            
                changeValueBy(village.villageValue/sum * grandTotalPercent, time: goingDownTime)
                
                village.barNode.runAction(village.barAction) {
                    village.villageValue = 0
                    
                    self.currentVillageLabel.text = ""
                    
                    if !self.shouldStop {
                        self.emptyNextVillage()
                    }
                }
                break
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if rightLevelNode.hasActions() {
            updateLabels()
        }
        
        if !input.isEmpty {
            if input[0] == "x" {
                changeLevelValueTo(100)
                input = ""
            } else if contains("0123456789", input[0]) {
                if count(input) == 2 {
                    changeLevelValueTo(CGFloat(input[0...1].toInt()!))
                    input = ""
                }
            } else {
                input = ""
            }
        }
        
        if villageInAction != nil {
            if villageInAction!.barNode.hasActions() {
                currentVillageLabel.text = "\(villageInAction!.nameNode.text) → \(villageInAction!.valueNode.text)"
            }
        }
        
        let numMax = villageValuesList.reduce(0, combine: {max($0, $1)})
        
        if upVillages < 25 {
            for village in villageLabels {
                if village.barNode.hasActions() {
                    village.valueNode.text = String(format: "%.f", village.barNode.size.width / (village.size.width-160)*numMax)
                }
            }
        }
    }
    
    func updateLabels() {
        var currentRightLevel = (rightLevelNode.position.y - rightRectangle.origin.y) / rightRectangle.height * 100
        
        currentRightLevel = (currentRightLevel > 100) ? 100 : currentRightLevel
        currentRightLevel = (currentRightLevel < 0) ? 0 : currentRightLevel
        
        rightLevelLabel.text = String(format: "%.1f", currentRightLevel) + " %"
        
        rightLevelLabel.position.y = rightLevelNode.frame.origin.y + rightLevelNode.size.height + 10
        
        if currentRightLevel > 15 {
            rightLevelLabel.position.y -= 60
            rightLevelLabel.fontColor = NSColor.blackColor()
        } else {
            rightLevelLabel.fontColor = NSColor.blackColor()
        }
        
        if currentRightLevel >= 100 {
            rightLevelLabel.position.y = rightRectangle.origin.y + rightRectangle.height - 50
        }
        
        if currentRightLevel <= 0 {
            rightLevelLabel.position.y = rightRectangle.origin.y + 10
        }
    }
    
    func setupSkin() {
        if background?.parent == nil {
            background = SKSpriteNode(imageNamed: "background")
            background.zPosition = 1
            background.anchorPoint = CGPointZero
            background.physicsBody = nil
            world.addChild(background)
        }
        
        if mask?.parent == nil {
            mask = SKSpriteNode(imageNamed: "mask")
            mask.zPosition = 4
            mask.anchorPoint = CGPointZero
            mask.physicsBody = nil
            world.addChild(mask)
        }
    }
    
    func setupLabels() {
        if rightLevelLabel?.parent == nil {
            rightLevelLabel = SKLabelNode(fontNamed: "Papyrus")
            rightLevelLabel.position = CGPointMake(800, 20)
            rightLevelLabel.fontSize = 50
            rightLevelLabel.zPosition = 5
            rightLevelLabel.physicsBody = nil
            rightLevelLabel.fontColor = NSColor.blackColor()
            world.addChild(rightLevelLabel)
        }
        
        updateLabels()
        
        createVillageLabels()
        
        if currentVillageLabel?.parent == nil {
            currentVillageLabel = SKLabelNode(fontNamed: "Papyrus")
            currentVillageLabel.position = CGPointMake(scene!.size.width/2, 30)
            currentVillageLabel.fontColor = currentVillageColor
            currentVillageLabel.fontSize = 50
            currentVillageLabel.zPosition = 5
            currentVillageLabel.physicsBody = nil
            currentVillageLabel.text = ""
            world.addChild(currentVillageLabel)
        }
    }
    
    func setupLevels() {
        if rightLevelNode?.parent == nil {
            rightLevelNode = SKSpriteNode(color: rightGaugeColor, size: CGSizeMake(rightRectangle.size.width, rightRectangle.size.height * 2))
            rightLevelNode.position = CGPointMake(512 * 1.5, rightRectangle.origin.y)
            rightLevelNode.anchorPoint = CGPointMake(0.5, 1)
            rightLevelNode.alpha = 0.4
            rightLevelNode.zPosition = 2
            rightLevelNode.physicsBody = nil
            world.addChild(rightLevelNode)
            
            var toWhiteAction = SKAction.colorizeWithColor(NSColor.whiteColor(), colorBlendFactor: 1, duration: 0.05)
            var toGreenAction = SKAction.colorizeWithColor(rightGaugeColor, colorBlendFactor: 1, duration: 0.05)
            var waitAction = SKAction.waitForDuration(0.4)
            
            rightLevelBlinking = SKAction.repeatActionForever(SKAction.sequence([toWhiteAction, toGreenAction, waitAction]))
            
            energySaveLabel = SKLabelNode(fontNamed: "Papyrus")
            energySaveLabel.position = CGPointMake(780, 150)
            energySaveLabel.fontColor = NSColor.blackColor()
            energySaveLabel.text = "Energy save"
            energySaveLabel.fontSize = 40
            energySaveLabel.zPosition = 7
            energySaveLabel.physicsBody = nil
            energySaveLabel.alpha = 0
            world.addChild(energySaveLabel)
            
            var toFullAlphaAction = SKAction.fadeAlphaTo(1, duration: 0.05)
            var toNoAlphaAction = SKAction.fadeAlphaTo(0, duration: 0.05)
            
            energySaveBlinking = SKAction.repeatActionForever(SKAction.sequence([toFullAlphaAction, toNoAlphaAction, waitAction]))
        }
    }
    
    func createVillageLabels() {
        
        if labelList != nil {
            if labelList.children.isEmpty {
                villageLabels.removeAll(keepCapacity: false)
            
                for i in 0..<villageNameList.count {
                    var label = VillageLabelNode(frame: CGRectMake(leftRectangle.origin.x, leftRectangle.origin.y + leftRectangle.height - CGFloat(i) * (leftRectangle.height / CGFloat(villageNameList.count)), leftRectangle.width, leftRectangle.height / CGFloat(villageNameList.count)), name: villageNameList[i], value: villageValuesList[i])
                    villageLabels.append(label)
                    labelList.addChild(label)
                }
            }
        }
    }
    
    func changeLevelValueBy(value: CGFloat) {
        let levelMaxHeight = rightRectangle.height
        
        if value == 0 {
            return
        }
        
        var newlevel = rightLevel + value
        
        if newlevel > 100 {
            newlevel = 100
        } else if newlevel < 0 {
            newlevel = 0
        }
        
        var startPoint = rightLevelNode.position
        var endPoint = rightLevelNode.position
        endPoint.y += (newlevel - rightLevel) * levelMaxHeight / 100
        
        rightLevel = newlevel
        
        var duration = max(Double(abs(value)) / durationCoefficient, minEffectDuration)
        duration = min(duration, maxEffectDuration)
        
        let moveEffect = SKTMoveEffect(node: rightLevelNode, duration: duration, startPosition: startPoint, endPosition: endPoint)
        
        moveEffect.timingFunction = SKTCustomLiquidLevel
        
        rightLevelNode.runAction(SKAction.actionWithEffect(moveEffect))
    }
    
    func changeLevelValueTo(value: CGFloat) {
        changeLevelValueBy(value - rightLevel)
    }
    
    func changeValueBy(value: CGFloat, time: Double) {
        
        let levelMaxHeight = rightRectangle.height
        
        if value == 0 {
            return
        }
        
        var newlevel = rightLevel + value
        
        if newlevel > 100 {
            newlevel = 100
        } else if newlevel < 0 {
            newlevel = 0
        }
        
        var startPoint = rightLevelNode.position
        var endPoint = rightLevelNode.position
        endPoint.y += (newlevel - rightLevel) * levelMaxHeight / 100
        
        rightLevel = newlevel
        
        let moveEffect = SKTMoveEffect(node: rightLevelNode, duration: time, startPosition: startPoint, endPosition: endPoint)
        
        moveEffect.timingFunction = SKTTimingFunctionLinear
        
        rightLevelNode.runAction(SKAction.actionWithEffect(moveEffect))
    }
    
    func clearVillages() {
        labelList.removeAllChildren()
        labelList.removeFromParent()
    }
}
