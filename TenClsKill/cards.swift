//
//  cards.swift
//  tencls-kill
//
//  Created by ハイラル・ゼルダ on 2025/5/17.
//

import Foundation

//卡牌
class Card {
    init(suit: Suit, number: Int, name: CardName, realCard: Card? = nil, virtual: Bool = false) {
        self.id = Card.card_id
        Card.card_id += 1
        self.suit = suit
        self.number = number
        self.name = name
        if !virtual{
            if let rCard = realCard{
                self.realCard = rCard
            }
            else{
                self.realCard = self
            }
        }
        else{
            self.realCard = nil
        }
    }
    //全局id
    static var card_id: Int = 0
    let id: Int
    //花色点数
    var suit: Suit
    var number: Int
    //牌名
    var name: CardName
    //本体(若为转化牌)
    var realCard: Card?
    //是否可用
    var can_use:Bool = false
    
    func isConverted() -> Bool {
        if realCard === self{
            return false
        }
        return true
    }
}
