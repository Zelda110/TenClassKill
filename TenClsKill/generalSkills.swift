//
//  generalSkills.swift
//  TenClsKill
//
//  Created by ハイラル・ゼルダ on 17/8/2025.
//


class 回血0: Skill {
    override init() {
        super.init()
        self.name = "回血"
        self.timeReset = .round
        self.locked = false
    }
    override func canUse(occasion: Action, player: Int) -> Bool {
        if let oca = occasion as? ActionPoint {
            if oca.player == player && isHurted(player: player) {
                return true
            }
        }
        return false
    }
    override func exe(occasion: Action, player: Int) async {
        await Recover(parent: occasion, player: player, num: 1).exe()
    }
}

class 回血: SkillGroup {
    let name: String = "回血"
    let description: String = "鎖定技，出牌階段，若你已受傷，你回復1點體力。"
    let tag: [SkillTag] = [.locked]
    var skills: [Skill] = [回血0()]
    let type: SkillType = .common
}
