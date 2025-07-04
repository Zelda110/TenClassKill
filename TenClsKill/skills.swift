//
//  skills.swift
//  tencls-kill
//
//  Created by ハイラル・ゼルダ on 2025/5/31.
//

import Foundation

//技能
//class Skill {
//    init(
//        name: String,
//        locked: Bool = false,
//        can_use: @escaping (Skill, Action, Int) async -> Bool,
//        exe: @escaping (Skill, Action, Int) async -> Void,
//        time_reset: TimeReset = .game
//    ) {
//        self.name = name
//        self.locked = locked
//        self.can_use = can_use
//        self.exe = exe
//        self.time_reset = time_reset
//    }
//    let name: String  //技能名
//    let locked: Bool  //是否為鎖定技
//    let can_use: (Skill, Action, Int) async -> Bool  //是否可以使用
//    let exe: (Skill, Action, Int) async -> Void  //執行
//    var time: Int = 0  //使用次數
//    let time_reset: TimeReset  //使用次數恢復
//    let record: @Sendable (Skill, Action, Int) async -> Void = {
//        skl,
//        action,
//        usr in
//        await action.record(
//            record: "\(getGeneralName(player: usr))發動了技能\"\(skl.name)\""
//        )
//    }  //記錄
//}

//使用技能
class UseSkill: Action {
    init(parent: Action, skill: Skill, player: Int) {
        self.skill = skill
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))發動了技能\(skill.name)")
        skill.exe(occasion: self.parent!, player: player)
        await end()
    }
    var skill: Skill
    var player: Int
}

//技能
class Skill {
    init(name: String, timeReset: TimeReset = .game) {
        self.name = name
        self.timeReset = timeReset
    }
    let name: String  //技能名
    func canUse(occasion: Action, player: Int) -> Bool {
        return true
    }  //是否可以使用
    func exe(occasion: Action, player: Int) {
        return
    }  //執行
    var time: Int = 0  //使用次數
    let timeReset: TimeReset  //使用次數恢復時機
}

//技能組
class SkillGroup {
    init(
        name: String,
        description: String,
        tag: [SkillTag] = [],
        skills: [Skill]
    ) {
        self.name = name
        self.description = description
        self.tag = tag
        self.skills = skills
    }
    let name: String  //技能名
    let description: String  //技能描述
    let tag: [SkillTag]  //技能標籤
    let skills: [Skill]  //技能
}
