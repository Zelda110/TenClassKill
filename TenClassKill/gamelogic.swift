//
//  gamelogic.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.09.
//

import Foundation

//遊戲類
class MainGame{
    init(player_num: Int) {
        self.player_num = player_num
    }
    
    let player_num: Int
}

//玩家類
class Player{
    init(general: General) {
        self.general = general
        self.health = self.general.health
        self.max_health = self.general.max_health
    }
    
    //武將
    var general: General
    //區域
    var areas: [CardList] = [CardList(),CardList(),CardList()]
    //體力值
    var health: Int
    var max_health: Int
    
}

//卡牌列表
class CardList{
    var cardlist : [Card] = []
    //以id搜尋卡牌
    func search_for_card(id: Int) -> Card? {
        for card in cardlist {
            if card.id == id {
                return card
            }
        }
        return nil
    }
}

class Card{
    init(suit: Int, number: Int, name: Int=0) {
        self.id = Card.card_id
        Card.card_id += 1
        self.suit = suit
        self.number = number
        self.name = name
    }
    
    //全局id
    static var card_id: Int=0
    let id: Int
    //花色點數
    var suit: Int
    var number: Int
    //牌名
    var name: Int
}

class General{
    init(name: String, health: Int, max_health: Int, skills: [Skill]) {
        self.name = name
        self.health = health
        self.max_health = max_health
        self.skills = skills
    }
    
    //武將名
    let name: String
    
    //體力值
    let health: Int
    let max_health: Int
    //技能組
    let skills: [Skill]
}

class Skill{
    init(name: String, occasion: Int, lock: Bool=false) {
        self.name = name
        self.occasion = occasion
        self.lock = lock
    }
    
    //技能名
    let name: String
    //發動時機
    let occasion: Int
    //技能類型
    let lock: Bool//是否為鎖定技
}
