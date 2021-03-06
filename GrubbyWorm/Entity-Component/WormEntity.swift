//
//  Worm.swift
//  GrubbyWorm
//
//  Created by Wayne on 15/10/7.
//  Copyright © 2015年 GAME-CHINA.ORG. All rights reserved.
//

import GameplayKit
import SpriteKit

protocol WormDelegate: NSObjectProtocol {
    func wormDead(worm: WormEntity)
}

class WormEntity : Entity {
    
    weak var game: Game?
    
    weak var ui: UIEntity?
    
    var info: WormInfo
    
    var willCombo = false
    
    var comboCount = 0
    
    var delegate: WormDelegate?
    
    init(game: Game?, ui: UIEntity?) {
        self.game = game
        self.ui = ui
        
        info = WormInfo(name: "Grubby Worm", speed: Constant.worm_normal_speed, foot: 5, alive: true)
        
        super.init()
    }

    func fireTrigger(trigger: TriggerEntity) {
        if willCombo {
            if let uiSprite = ui?.componentForClass(UISpriteComponent) {
                uiSprite.moodBar.percent = 100
                uiSprite.moodBar.comboCount = comboCount
            }
            comboCount++
        } else {
            willCombo = true
        }
        
        let addScore = (comboCount == 0 ? 1 : comboCount)
        game?.score += addScore
        
        if comboCount > 0 && info.speed != Constant.worm_combo_speed {
            if let wormStateMachine = componentForClass(WormControlComponent)?.stateMachine {
                if wormStateMachine.currentState == wormStateMachine.stateForClass(WormHappyState) {
                    info.speed = Constant.worm_combo_speed
                }
            }
        }
    }
    
    func resetCombo() {
        if let uiSprite = ui?.componentForClass(UISpriteComponent) {
            uiSprite.moodBar.percent = 0
            uiSprite.moodBar.comboCount = 0
        }
        
        comboFail()
    }
    
    func comboFail() {
        print("combo fail.")
        
        willCombo = false
        comboCount = 0
        
        if let wormStateMachine = componentForClass(WormControlComponent)?.stateMachine {
            if wormStateMachine.currentState == wormStateMachine.stateForClass(WormHappyState) {
                info.speed = Constant.worm_normal_speed
            }
        }
    }
    
    func happy() {
        if let controlComponent = componentForClass(WormControlComponent) {
            controlComponent.stateMachine?.enterState(WormHappyState)
        }
        
        if let energyInfo = game?.energy {
            var info = energyInfo
            
            info.current = 0
            info.round++
            info.total = (info.round * 10) + 100
            
            game?.energy = info
        }
        
        if comboCount > 0 {
            info.speed = Constant.worm_combo_speed
        } else {
            info.speed = Constant.worm_normal_speed
        }
    }
    
    func crazy() {
        info.speed = Constant.worm_crazy_speed
//        if let controlComponent = componentForClass(WormControlComponent) {
//            controlComponent.stateMachine?.enterState(WormCrazyState)
//        }
    }
    
    func headLocation() -> Location {
        if let spriteComponent = componentForClass(WormSpriteComponent) {
            return spriteComponent.locations[0]
        }
        
        return Location(row: 0, col: 0)
    }
    
    func tailLocation() -> Location {
        if let spriteComponent = componentForClass(WormSpriteComponent) {
            return spriteComponent.locations[spriteComponent.locations.count - 1]
        }
        
        return Location(row: 0, col: 0)
    }
    
    func eat(trigger: TriggerEntity) {
        fireTrigger(trigger)
        
        if let digestiveComponent = componentForClass(WormDigestiveComponent) {
            digestiveComponent.eat(trigger)
        }
    }
    
    func shit() {
        if let digestiveComponent = componentForClass(WormDigestiveComponent) {
            if digestiveComponent.haveShit() {
                digestiveComponent.shit()
            }
        }
    }
    
    func die() {
        comboFail()
        
        info.alive = false
        delegate?.wormDead(self)
        
        // play the sound 
        if let wormSprite = componentForClass(WormSpriteComponent) {
            wormSprite.root.runAction(SKAction.playSoundFileNamed(Constant.lose_sound, waitForCompletion: false))
        }
    }
}
