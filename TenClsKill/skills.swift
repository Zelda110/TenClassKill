//
//  skills.swift
//  tencls-kill
//
//  Created by ハイラル・ゼルダ on 2025/5/31.
//

import Foundation

//技能
class Skill {
    init(
        name: String,
        locked: Bool = false,
        can_use: @escaping (Skill, Action, Int) async -> Bool,
        exe: @escaping (Skill, Action, Int) async -> Void,
        time_reset: TimeReset = .game
    ) {
        self.name = name
        self.locked = locked
        self.can_use = can_use
        self.exe = exe
        self.time_reset = time_reset
    }
    let name: String  //技能名
    let locked: Bool  //是否为锁定技
    let can_use: (Skill, Action, Int) async -> Bool  //是否可以使用
    let exe: (Skill, Action, Int) async -> Void  //执行
    var time: Int = 0  //使用次数
    let time_reset: TimeReset  //使用次数恢复
    let record: @Sendable (Skill, Action, Int) async -> Void = {
        skl,
        action,
        usr in
        await action.record(
            record: "\(getGeneralName(player: usr))发动了技能\"\(skl.name)\""
        )
    }  //记录
}

//技能组
class SkillGroup {
    //完整初始化
    init(skills: [Skill], name: String? = nil, description: String) {
        self.skills = skills
        self.description = description
        if let na = name {
            self.name = na
        } else {
            self.name = skills[0].name
        }
    }
    //只有一种发动时机技能的简便初始化
    init(
        name: String,
        description: String,
        locked: Bool = false,
        can_use: @escaping (Skill, Action, Int) async -> Bool,
        exe: @escaping (Skill, Action, Int) async -> Void,
        time_reset: TimeReset = .game
    ) {
        self.skills = [
            Skill(
                name: name,
                locked: locked,
                can_use: can_use,
                exe: exe,
                time_reset: time_reset
            )
        ]
        self.name = skills[0].name
        self.description = description
    }
    let skills: [Skill]  //技能
    let name: String  //技能名
    let description: String  //技能描述
}

//TEST
let 回血 = SkillGroup(
    name: "回血",
    description: "出牌阶段，若你已受伤，你可以回复1点体力。",
    can_use: { skl, occasion, usr in
        if let oca = occasion as? ActionPoint {
            if await oca.player == usr
                && isHurted(player: oca.player)
            {
                return true
            }
        }
        return false
    },
    exe: { skl, oca, usr in
        Action.tabs += 1
        await skl.record(skl, oca, usr)

        await Recover(parent: oca, player: usr, num: 1).exe()

        Action.tabs -= 1
    }
)

let 失血 = SkillGroup(
    name: "失血",
    description: "一名角色的出牌阶段开始时，你可以令其失去1点体力。",
    can_use: { skl, occasion, usr in
        if let oca = occasion as? StageStart {
            if await oca.stage == .ACTION && skl.time < 1 {
                return true
            }
        }
        return false
    },
    exe: { skl, oca, usr in
        Action.tabs += 1
        await skl.record(skl, oca, usr)

        skl.time += 1
        await LoseHealth(
            parent: oca,
            player: (oca as! StageStart).player,
            num: 1
        )
        .exe()

        Action.tabs -= 1
    },
    time_reset: .stage
)
