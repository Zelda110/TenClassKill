//
//  generals.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.16.
//

import Foundation

//武將
class General {
    init(
        name: String,
        health: Int,
        max_health: Int,
        shield: Int = 0,
        skills: [SkillGroup],
        card: GeneralCard,
        set: GeneralSet,
        subject: Subject,
        gender: Gender
    ) {
        self.name = name
        self.health = health
        self.max_health = max_health
        self.skills = skills
        self.card = card
        self.set = set
        self.subject = subject
        self.shield = shield
        self.gender = gender
    }

    //武將名
    let name: String

    //體力值
    let health: Int
    let max_health: Int
    let shield: Int
    //技能組
    let skills: [SkillGroup]

    //武將牌
    let card: GeneralCard
    //將包
    let set: GeneralSet
    //勢力
    let subject: Subject
    //性別
    let gender: Gender

    func get_image() -> String {
        return set.rawValue + "." + card.rawValue
    }
}

let WCY = General(
    name: "王成悅",
    health: 2,
    max_health: 3,
    skills: [回血()],
    card: .wcy,
    set: .標準包,
    subject: .BIOLOGY,
    gender: .male
)

let LQE = General(
    name: "劉奇恩",
    health: 4,
    max_health: 4,
    skills: [],
    card: .lqe,
    set: .標準包,
    subject: .MATH,
    gender: .male
)

let LCY = General(
    name: "劉宸驛",
    health: 4,
    max_health: 4,
    skills: [],
    card: .lcy,
    set: .標準包,
    subject: .INFORMATICS,
    gender: .male
)

let ZWX = General(
    name: "張文軒",
    health: 3,
    max_health: 3,
    skills: [],
    card: .zwx,
    set: .標準包,
    subject: .BIOLOGY,
    gender: .male
)
