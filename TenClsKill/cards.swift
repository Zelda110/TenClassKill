//
//  cards.swift
//  tencls-kill
//
//  Created by ハイラル・ゼルダ on 2025/5/17.
//

import Foundation

//牌名
struct CardName {
    var name: String  //名字
    var descripsion: String  //描述
    var skillGroupList: [SkillGroup]  //技能
    var image: String  //圖片
}

//卡牌(廣義)
class Card {
    init(suit: Suit, number: Int, cardName: CardName) {
        self.suit = suit
        self.number = number
        self.cardName = cardName
    }
    var suit: Suit
    var number: Int
    var cardName: CardName
}

//遊戲牌(實體)
class GameCard {
    //標準初始化
    init(info: [Card], modified: Card? = nil) {
        self.info = info
        self.modified = modified
        self.id = GameCard.cardId
        GameCard.cardId += 1
    }
    static var cardId = 0
    var id: Int
    var info: [Card]  //本體印刷信息
    var modified: Card?  //轉化後牌
    var isVirtual: Bool {  //是否是虛擬牌
        return info.isEmpty
    }
    var isModified: Bool {  //是否是轉化牌
        return !(modified == nil)
    }
    var card: Card {  //獲取實際顯示的牌
        if let card = modified {
            return card
        } else {
            return info[0]
        }
    }
    var cardName: CardName {
        return card.cardName
    }
    var suit: Suit {
        return card.suit
    }
    var number: Int {
        return card.number
    }
    func clearModification() {
        self.modified = nil
    }
}

//class Card {
//    init(suit: Suit, number: Int, name: CardName, realCard: Card? = nil, virtual: Bool = false) {
//        self.id = Card.card_id
//        Card.card_id += 1
//        self.suit = suit
//        self.number = number
//        self.name = name
//        if !virtual{
//            if let rCard = realCard{
//                self.realCard = rCard
//            }
//            else{
//                self.realCard = self
//            }
//        }
//        else{
//            self.realCard = nil
//        }
//    }
//    //全局id
//    static var card_id: Int = 0
//    let id: Int
//    //花色點數
//    var suit: Suit
//    var number: Int
//    //牌名
//    var name: CardName
//    //本體(若為轉化牌)
//    var realCard: Card?
//    //是否可用
//    var can_use:Bool = false
//
//    func isConverted() -> Bool {
//        if realCard === self{
//            return false
//        }
//        return true
//    }
//}

//遊戲牌技能
class PeachActionPoint: Skill {
    let name: String = "桃"
    func canUse(occasion: Action, player: Int) -> Bool {
        if let oca = occasion as? RunStage {
            if oca.stage == .DRAWING && oca.player == player {
                return true
            }
        }
        return false
    }
    func exe(occasion: Action, player: Int) async {
        await DrawCard(parent: occasion, player: player, num: 2).exe()
    }
    var time: Int = 0
    let timeReset: TimeReset = .game
    let locked: Bool = false
}

class PeachSkill: SkillGroup {
    let name: String = "桃"
    let description: String = "出牌階段，對自己使用，或對一名瀕死角色使用，回復1點體力。"
    let tag: [SkillTag] = []
    var skills: [Skill] = [PeachActionPoint()]
    let type: SkillType = .card
}

//所有牌名
let PEACH = CardName(
    name: "桃",
    descripsion: "",
    skillGroupList: [PeachSkill()],
    image: "peach"
)
