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
        await skill.exe(occasion: self, player: player)
        await end()
    }
    var skill: Skill
    var player: Int
}

//技能
protocol Skill {
    var name: String { get }  //技能名
    func canUse(occasion: Action, player: Int) -> Bool  //是否可以使用
    func exe(occasion: Action, player: Int) async  //執行
    var time: Int { get set }  //使用次數
    var timeReset: TimeReset { get }  //使用次數恢復時機
    var locked: Bool { get }  //是否必須發動
}

//技能組
protocol SkillGroup {
    var name: String { get }  //技能名
    var description: String { get }  //技能描述
    var tag: [SkillTag] { get }  //技能標籤
    var skills: [Skill] { get set }  //技能
    var type: SkillType { get }  //技能種類
}

//遊戲機制
let SystemSkills = [DrawCardSkill()]

class DrawCardSkill0: Skill {
    let name: String = "摸牌"
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
    let timeReset: TimeReset = .stage
    let locked: Bool = true
}

class DrawCardSkill: SkillGroup {
    let name: String = "摸牌"
    let description: String = "鎖定技，摸牌階段，你摸兩張牌。"
    let tag: [SkillTag] = [.locked]
    var skills: [Skill] = [DrawCardSkill0()]
    let type: SkillType = .system
}

//武將技能
class 回血0: Skill{
    let name: String = "回血"
    func canUse(occasion: Action, player: Int) -> Bool {
        if let oca = occasion as? ActionPoint {
            if oca.player == player && isHurted(player: player){
                return true
            }
        }
        return false
    }
    func exe(occasion: Action, player: Int) async {
        await Recover(parent: occasion, player: player, num: 1).exe()
    }
    var time: Int = 0
    let timeReset: TimeReset = .round
    let locked: Bool = false
}

class 回血: SkillGroup{
    let name: String = "回血"
    let description: String = "鎖定技，出牌階段，若你已受傷，你回復1點體力。"
    let tag: [SkillTag] = [.locked]
    var skills: [Skill] = [回血0()]
    let type: SkillType = .common
}
