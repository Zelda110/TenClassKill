//
//  consts.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.09.
//

import Foundation
import SwiftUI

let Nunber: [String] = [
    "0",
    "A",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "J",
    "Q",
    "K"
]

enum Suit:String {
    case SPADES = "spades"//黑桃
    case HEARTS = "hearts"//紅桃
    case DIAMONDS = "diamonds"//方塊
    case CLUBS = "clubs"//梅花
}

//獲取花色對應的顏色
func getSuitColor(suit:Suit) -> Color{
    switch suit{
    case .CLUBS,.SPADES:
        return Color.black
    case .DIAMONDS,.HEARTS:
        return Color.red
    }
}

enum Stage:String {
    case PREPARATION = "準備階段"
    case JUDGEMENT = "判定階段"
    case DRAWING = "摸牌階段"
    case ACTION = "出牌階段"
    case DISCARD = "棄牌階段"
    case ENDING = "結束階段"
}

enum CardType:Int {
    case BASIC = 0//基本
    case SCROLL//錦囊
    case EQUIPMENT//裝備
}

enum Area:Int{
    case HANDCARD = 0//手牌區
    case EQUIPMENT//裝備區
    case JUDGEMENT//判定區
    case CARDDESK//牌堆
    case DISCARDDESK//棄牌堆
}

enum Subject:String{
    case GOD = "god"
    case MATH = "math"
    case PHYSICS = "physics"
    case CHEMISTRY = "chemistry"
    case BIOLOGY = "biology"
    case INFORMATICS = "informatics"
    case ENGLISH = "english"
    case CHINESE = "chinese"
}

//獲取學科對應的名稱
func getSubjectName(sub:Subject) -> String {
    switch sub {
    case .GOD:
        return "神"
    case .MATH:
        return "數學"
    case .PHYSICS:
        return "物理"
    case .CHEMISTRY:
        return "化學"
    case .BIOLOGY:
        return "生物"
    case .INFORMATICS:
        return "信息"
    case .ENGLISH:
        return "英語"
    case .CHINESE:
        return "語文"
    }
}

enum Role:Int{
    case MONARCH = 0//主公
    case MINISTER//忠臣
    case REBEL//反賊
    case TRAITORS//內奸
}

enum CardName:String{
    case 殺 = "strike"
    case 閃 = "dodge"
    case 桃 = "peach"
    case 酒 = "wine"
    case 加多寶 = "JDB"
    case 叫父陷阱 = "call_8"
    case 秋風掃落葉 = "cold_like_autumn"
    case DUTY = "DUTY"
    case 教室打牌 = "playing_cards_in_class"
    case 座位表 = "seat_sheet"
    case 跑操站樁 = "stand_while_running"
    case 春天般溫暖 = "warm_like_spring"
    case 信手拈來 = "xinshounianlai"
}

enum GeneralCard:String{
    case yyl = "yyl"
    case lqe = "lqe"
    case wcy = "wcy"
    case zwx = "zwx"
    case lcy = "lcy"
}

enum Gender:String{
    case male = "男"
    case female = "女"
}

enum GeneralSet:String{
    case 標準包 = "basic"
}

//限制次數恢復週期
enum TimeReset{
    case round
    case turn
    case stage
    case game
}

//選擇種類
enum ChooseType{
    case common
    case card
}

//技能標籤
enum SkillTag{
    case locked //鎖定技
    case limited //限定技
    case awake //覺醒技
    case switching //轉換技
    case mission //使命技
}
