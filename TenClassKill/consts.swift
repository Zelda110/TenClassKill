//
//  consts.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.09.
//

import Foundation

let NUMBER: [String] = [
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

struct SUIT {
    let SPADES = 0//黑桃
    let HEARTS = 1//紅桃
    let DIAMONDS = 2//方塊
    let CLUBS = 3//梅花
}

struct STAGE {
    let PREPARATION = 0//准备阶段
    let JUDGEMENT = 1//判定階段
    let DRAWING = 2//摸牌階段
    let ACTION = 3//出牌階段
    let DISCARD = 4//棄牌階段
    let ENDING = 5//結束階段
}

struct CARD_TYPE {
    let BASIC = 0//基本
    let SCROLL = 1//錦囊
    let EQUIPMENT = 2//裝備
}

struct AREA{
    let HANDCARD = 0//手牌區
    let EQUIPMENT = 1//裝備區
    let JUDGEMENT = 2//判定區
}

struct SUBJECT{
    let GOD = 0
    let MATH = 1
    let PHYSICS = 2
    let CHEMISTRY = 3
    let BIOLOGY = 4
    let INFORMATICS = 5
    let ENGLISH = 6
    let CHINESE = 7
    let TEACHERS = 8
}

struct ROLE{
    let MONARCH = 0//主公
    let MINISTER = 1//忠臣
    let REBEL = 2//反賊
    let TRAITORS = 3//內奸
}

struct CARDNAME{
    let 殺 = 0
    let 閃 = 1
    let 桃 = 2
    let 酒 = 3
    let 加多寶 = 4
}
