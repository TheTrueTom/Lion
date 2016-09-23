//
//  GameScene.swift
//  Lion
//
//  Created by Thomas Brichart on 01/07/2015.
//  Copyright (c) 2015 Thomas Brichart. All rights reserved.
//

import SpriteKit

let durationCoefficient: Double = 1
let minEffectDuration: Double = 3
let maxEffectDuration: Double = 10

enum Gauge {
    case Left
    case Right
}

class GameScene: SKScene {
    
    var world: SKNode!
    
    var leftLevelNode: SKSpriteNode!
    var rightLevelNode: SKSpriteNode!
    
    var leftLevel: CGFloat = 0
    var rightLevel: CGFloat = 0
    
    var leftLevelLabel: SKLabelNode!
    var rightLevelLabel: SKLabelNode!
    
    var input: String = ""
    
    /** Initial location for window dragging set on mouseDown*/
    var initialLocation: NSPoint!
    
    var mask: SKSpriteNode!
    var background: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        world = SKNode()
        
        if world?.parent == nil {
            self.addChild(world)
        }
        
        setupSkin()
        setupLabels()
        setupLevels()
        updateLabels()
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        println(theEvent.locationInNode(world))
        
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
            case "o":
                changeLevelValueOf(.Left, by: 0.1)
            case "p":
                changeLevelValueOf(.Right, by: 0.1)
            case "l":
                changeLevelValueOf(.Left, by: -0.1)
            case "m":
                changeLevelValueOf(.Right, by: -0.1)
            case ":":
                changeLevelValueOf(.Left, to: 0)
            case "=":
                changeLevelValueOf(.Right, to: 0)
            case "x", "b", "t", "g", "d", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                input += character
            default:
                break
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        if rightLevelNode.hasActions() || leftLevelNode.hasActions() {
            updateLabels()
        }
        
        if !input.isEmpty {
            if contains("gd", input[0]) {
                if count(input) == 3 {
                    if let value = input[1...2].toInt() {
                        var gauge: Gauge = (input[0] == "d") ? .Right : .Left
                        changeLevelValueOf(gauge, to: CGFloat(value))
                    }
                    
                    input = ""
                } else if count(input) == 2 {
                    if input[1] == "x" {
                        var gauge: Gauge = (input[0] == "d") ? .Right : .Left
                        changeLevelValueOf(gauge, to: 100)
                        input = ""
                    }
                }
            } else if input[0] == "b" {
                if count(input) == 3 {
                    if let value = input[1...2].toInt() {
                        changeLevelValueOf(.Left, to: CGFloat(value))
                        changeLevelValueOf(.Right, to: CGFloat(value))
                    }
                    
                    input = ""
                } else if count(input) == 2 && input[1] == "x" {
                    changeLevelValueOf(.Left, to: 100)
                    changeLevelValueOf(.Right, to: 100)
                }
            } else if input[0] == "t" {
                if count(input) == 5 {
                    if input[1] == "g" {
                        if input[2] == "d" {
                            if let value = input[3...4].toInt() {
                                transferFrom(Gauge.Left, to: Gauge.Right, value: CGFloat(value))
                            }
                        }
                    } else if input[1] == "d" {
                        if input[2] == "g" {
                            if let value = input[3...4].toInt() {
                                transferFrom(Gauge.Right, to: Gauge.Left, value: CGFloat(value))
                            }
                        }
                    }
                    
                    self.input = ""
                }
            } else {
                self.input = ""
            }
        }
    }

    func transferFrom(gauge: Gauge, to secondGauge: Gauge, value: CGFloat) {
        var currentLevel = (gauge == .Left) ? leftLevel : rightLevel
        var transfer = value
        
        if transfer > currentLevel {
            transfer = currentLevel
        }
        
        changeLevelValueOf(gauge, by: -transfer)
        changeLevelValueOf(secondGauge, by: transfer)
    }

    func changeLevelValueOf(gauge: Gauge, by value: CGFloat) {
        
        var levelNode: SKSpriteNode = (gauge == .Left) ? leftLevelNode : rightLevelNode
        var level: CGFloat = (gauge == .Left) ? leftLevel : rightLevel
        let levelMaxHeight = (gauge == .Left) ? leftRectangle.height : rightRectangle.height
        
        if value == 0 {
            return
        }
        
        var newlevel = level + value
        
        if newlevel > 100 {
            newlevel = 100
        } else if newlevel < 0 {
            newlevel = 0
        }
        
        var startPoint = levelNode.position
        var endPoint = levelNode.position
        endPoint.y += (newlevel - level) * levelMaxHeight / 100
        
        switch gauge {
        case .Left:
            leftLevel = newlevel
        case .Right:
            rightLevel = newlevel
        default:
            fatalError("Wrong gauge called in changeLevelOf(gauge: by:)")
        }
        
        var duration = max(Double(abs(value)) / durationCoefficient, minEffectDuration)
        duration = min(duration, maxEffectDuration)
        
        let moveEffect = SKTMoveEffect(node: levelNode, duration: duration, startPosition: startPoint, endPosition: endPoint)
        
        moveEffect.timingFunction = SKTCustomLiquidLevel
        
        levelNode.runAction(SKAction.actionWithEffect(moveEffect))
    }
    
    func changeLevelValueOf(gauge: Gauge, to value: CGFloat) {
        
        var level: CGFloat
        
        switch gauge {
        case .Left:
            level = leftLevel
        case .Right:
            level = rightLevel
        default:
            break
        }
        
        changeLevelValueOf(gauge, by: value - level)
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
    
    func setupLevels() {
        if leftLevelNode?.parent == nil {
            leftLevelNode = SKSpriteNode(color: NSColor.redColor(), size: CGSizeMake(leftRectangle.size.width, leftRectangle.size.height * 2))
            leftLevelNode.position = CGPointMake(512 * 0.5, leftRectangle.origin.y)
            leftLevelNode.anchorPoint = CGPointMake(0.5, 1)
            leftLevelNode.alpha = 0.4
            leftLevelNode.zPosition = 2
            leftLevelNode.physicsBody = nil
            world.addChild(leftLevelNode)
        }
        
        if rightLevelNode?.parent == nil {
            rightLevelNode = SKSpriteNode(color: NSColor.greenColor(), size: CGSizeMake(rightRectangle.size.width, rightRectangle.size.height * 2))
            rightLevelNode.position = CGPointMake(512 * 1.5, rightRectangle.origin.y)
            rightLevelNode.anchorPoint = CGPointMake(0.5, 1)
            rightLevelNode.alpha = 0.4
            rightLevelNode.zPosition = 2
            rightLevelNode.physicsBody = nil
            world.addChild(rightLevelNode)
        }
    }
    
    func setupLabels() {
        if leftLevelLabel?.parent == nil {
            leftLevelLabel = SKLabelNode(fontNamed: "Papyrus")
            leftLevelLabel.position = CGPointMake(250, 20)
            leftLevelLabel.fontSize = 50
            leftLevelLabel.zPosition = 5
            leftLevelLabel.physicsBody = nil
            leftLevelLabel.fontColor = NSColor.blackColor()
            world.addChild(leftLevelLabel)
        }
        
        if rightLevelLabel?.parent == nil {
            rightLevelLabel = SKLabelNode(fontNamed: "Papyrus")
            rightLevelLabel.position = CGPointMake(800, 20)
            rightLevelLabel.fontSize = 50
            rightLevelLabel.zPosition = 5
            rightLevelLabel.physicsBody = nil
            rightLevelLabel.fontColor = NSColor.blackColor()
            world.addChild(rightLevelLabel)
        }
    }
    
    func updateLabels() {
        var currentLeftLevel = (leftLevelNode.position.y - leftRectangle.origin.y) / leftRectangle.height * 100
        var currentRightLevel = (rightLevelNode.position.y - rightRectangle.origin.y) / rightRectangle.height * 100
        
        currentLeftLevel = (currentLeftLevel > 100) ? 100 : currentLeftLevel
        currentLeftLevel = (currentLeftLevel < 0) ? 0 : currentLeftLevel
        
        currentRightLevel = (currentRightLevel > 100) ? 100 : currentRightLevel
        currentRightLevel = (currentRightLevel < 0) ? 0 : currentRightLevel
        
        leftLevelLabel.text = String(format: "%.1f", currentLeftLevel) + " %"
        rightLevelLabel.text = String(format: "%.1f", currentRightLevel) + " %"
        
        leftLevelLabel.position.y = leftLevelNode.frame.origin.y + leftLevelNode.size.height + 10
        rightLevelLabel.position.y = rightLevelNode.frame.origin.y + rightLevelNode.size.height + 10
        
        if currentLeftLevel > 15 {
            leftLevelLabel.position.y -= 60
            leftLevelLabel.fontColor = NSColor.blackColor()
        } else {
            leftLevelLabel.fontColor = NSColor.blackColor()
        }
        
        if currentRightLevel > 15 {
            rightLevelLabel.position.y -= 60
            rightLevelLabel.fontColor = NSColor.blackColor()
        } else {
            rightLevelLabel.fontColor = NSColor.blackColor()
        }
        
        if currentLeftLevel >= 100 {
            leftLevelLabel.position.y = leftRectangle.origin.y + leftRectangle.height - 50
        }
        
        if currentRightLevel >= 100 {
            rightLevelLabel.position.y = rightRectangle.origin.y + rightRectangle.height - 50
        }
        
        if currentLeftLevel <= 0 {
            leftLevelLabel.position.y = leftRectangle.origin.y + 10
        }
        
        if currentRightLevel <= 0 {
            rightLevelLabel.position.y = rightRectangle.origin.y + 10
        }
    }
}
