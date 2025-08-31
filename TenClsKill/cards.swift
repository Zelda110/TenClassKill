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
    var skillGroups: [SkillGroup]  //技能
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

//遊戲牌
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
    var display: String {
        return "\(cardName.name)[\(suit.rawValue) \(number)]"
    }
    func clearModification() {
        self.modified = nil
    }
}

//使用牌
class UseCard: Action {
    init(parent: Action, card: GameCard, player: Int, skill: Skill) {
        self.card = card
        self.player = player
        self.skill = skill
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        await askSkill()
        record("\(getGeneralName(player: player))使用了")
        if card.isVirtual {
            Action.mainGame!.dealingList.add_card(card: card)
        }
        else{
            Action.mainGame!.set_card_position(
                id: card.id,
                from: Action.mainGame!.players[player].areas[Area.HANDCARD.rawValue],
                to: Action.mainGame!.dealingList
            )
        }
        await skill.exe(occasion: self, player: player)
        if card.isVirtual {
            let _ = Action.mainGame!.dealingList.remove_card(id: card.id)
        }
        else{
            if let c = Action.mainGame!.dealingList.search_for_card(id: card.id){
                c.0.clearModification()
                Action.mainGame!.set_card_position(
                    id: card.id,
                    from: Action.mainGame!.dealingList,
                    to: Action.mainGame!.discardedList
                )
            }
        }
        await end()
    }
    var card: GameCard
    var player: Int
    var skill: Skill
}

//遊戲牌技能
class PeachActionPoint: Skill {
    override init() {
        super.init()
        self.name = "桃"
        self.timeReset = .game
        self.locked = false
    }
    override func canUse(occasion: Action, player: Int) -> Bool {
        if let oca = occasion as? ActionPoint {
            if oca.player == player
                && isHurted(
                    player: player
                )
            {
                return true
            }
        }
        return false
    }
    override func exe(occasion: Action, player: Int) async {
        await Recover(parent: occasion, player: player, num: 1).exe()
    }
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
    skillGroups: [PeachSkill()],
    image: "peach"
)
