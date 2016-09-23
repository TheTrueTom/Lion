//
//  AppDelegate.swift
//  Lion
//
//  Created by Thomas Brichart on 01/07/2015.
//  Copyright (c) 2015 Thomas Brichart. All rights reserved.
//


import Cocoa
import SpriteKit

let font = "Papyrus"

let leftRectangle = CGRectMake(12, 74, 488, 420)
let rightRectangle = CGRectMake(524, 71, 488, 424)

extension SKNode {
    class func unarchiveFromFile(file : String, type: String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            
            let scene: SKScene!
            
            if type == "Other" {
                scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! OtherGameScene
            } else {
                scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            }
            
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var window: LionWindow!
    @IBOutlet weak var skView: SKView!
    
    @IBOutlet weak var prefPanel: NSPanel!
    @IBOutlet weak var prefPanelView: NSView!
    
    @IBOutlet weak var grandTotalPercentTextField: NSTextField!
    @IBOutlet weak var goingDownTimeTextField: NSTextField!
    @IBOutlet weak var barTimeUpTextField: NSTextField!
    
    var mainScene: GameScene!
    var otherScene: OtherGameScene!
    
    @IBAction func switchClicked(sender: AnyObject) {
        if self.skView!.scene == mainScene {
            self.skView!.presentScene(otherScene, transition: SKTransition.doorwayWithDuration(1))
        } else {
            self.skView!.presentScene(mainScene, transition: SKTransition.doorwayWithDuration(1))
        }
    }
    
    @IBAction func prefClicked(sender: AnyObject) {
        setupPrefPanel()
        prefPanel.makeKeyAndOrderFront(sender)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.skView!.ignoresSiblingOrder = true
        
        if let scene = GameScene.unarchiveFromFile("GameScene", type: "Main") as? GameScene {
            mainScene = scene
            mainScene.scaleMode = .AspectFill
            
            self.skView!.presentScene(mainScene)
        }
        
        if let scene = OtherGameScene.unarchiveFromFile("GameScene", type: "Other") as? OtherGameScene {
            otherScene = scene
            otherScene.scaleMode = .AspectFill
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
    
    func setupPrefPanel() {
        for i in 0..<villageNameList.count {
            var label: NSTextField = NSTextField(frame: NSMakeRect(5, CGFloat(25*i + 5), 200, 20))
            label.stringValue = villageNameList[i]
            label.editable = false
            label.bordered = false
            label.bezeled = false
            label.selectable = false
            label.backgroundColor = NSColor.clearColor()
            prefPanelView.addSubview(label)
            
            var valueLabel: NSTextField = NSTextField(frame: NSMakeRect(205, CGFloat(25*i + 5), 45, 20))
            valueLabel.floatValue = Float(villageValuesList[i])
            valueLabel.editable = true
            valueLabel.bordered = true
            valueLabel.bezeled = true
            valueLabel.selectable = true
            valueLabel.backgroundColor = NSColor.whiteColor()
            valueLabel.tag = i
            valueLabel.delegate = self
            prefPanelView.addSubview(valueLabel)
        }
        
        grandTotalPercentTextField.floatValue = Float(grandTotalPercent)
        grandTotalPercentTextField.delegate = self
        
        goingDownTimeTextField.doubleValue = goingDownTime
        goingDownTimeTextField.delegate = self
        
        barTimeUpTextField.doubleValue = barTimeUp
        barTimeUpTextField.delegate = self
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if let textfield = obj.object as? NSTextField {
            if textfield.tag == 97 {
                barTimeUp = barTimeUpTextField.doubleValue
                println("New barTimeUp: \(barTimeUp)")
            } else if textfield.tag == 98 {
                goingDownTime = goingDownTimeTextField.doubleValue
                println("New goingDownTime: \(goingDownTime)")
            } else if textfield.tag == 99 {
                grandTotalPercent = CGFloat(grandTotalPercentTextField.floatValue)
                println("New grandTotalPercent: \(grandTotalPercent)")
            } else {
                villageValuesList[textfield.tag] = CGFloat(textfield.floatValue)
            }
            otherScene.createVillageLabels()
        }
    }
}
