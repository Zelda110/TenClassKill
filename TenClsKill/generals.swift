//
//  generals.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.16.
//

import Foundation

//武将
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

    //武将名
    let name: String

    //体力值
    let health: Int
    let max_health: Int
    let shield: Int
    //技能组
    let skills: [SkillGroup]

    //武将牌
    let card: GeneralCard
    //将包
    let set: GeneralSet
    //势力
    let subject: Subject
    //性别
    let gender: Gender

    func get_image() -> String {
        return set.rawValue + "." + card.rawValue
    }
}

let WCY = General(
    name: "王成悦",
    health: 2,
    max_health: 3,
    skills: [回血,失血],
    card: .wcy,
    set: .标准包,
    subject: .BIOLOGY,
    gender: .male
)

let LQE = General(
    name: "刘奇恩",
    health: 4,
    max_health: 4,
    skills: [],
    card: .lqe,
    set: .标准包,
    subject: .MATH,
    gender: .male
)

let LCY = General(
    name: "刘宸驿",
    health: 4,
    max_health: 4,
    skills: [],
    card: .lcy,
    set: .标准包,
    subject: .INFORMATICS,
    gender: .male
)

let ZWX = General(
    name: "张文轩",
    health: 3,
    max_health: 3,
    skills: [],
    card: .zwx,
    set: .标准包,
    subject: .BIOLOGY,
    gender: .male
)
