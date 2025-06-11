//
//  actions.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.04.13.
//

import Foundation

//游戏行为
class Action {
    init(parent: Action?, usetab: Bool = true) {
        self.parent = parent
        self.use_tab = usetab
    }
    func exe() async {

    }

    //自动操作
    func start() async{
        if use_tab {
            Action.tabs += 1
        }
        Action.mainGame!.now_action = self
        await AskSkill(parent: self).exe()
        try? await Task.sleep(nanoseconds: 10_000_000)
    }
    func end() async {
        if use_tab {
            Action.tabs -= 1
        }
        try? await Task.sleep(nanoseconds: 10_000_000)
    }

    static var tabs = 0  //记录层级
    static var mainGame: MainGame? = nil  //主游戏
    var parent: Action?  //父行为
    var use_tab: Bool  //是否使用缩进
    //添加记录
    func record(record: String) {
        Action.mainGame!.records
            .insert(
                Record(record: record, tabs: Action.tabs, self_id: Record.id),
                at: 0
            )
        Record.id += 1
        if DEBUG_MODE {
            print(record)
        }
    }
}

//游戏开始时
class GameStart: Action {
    override func exe() async {
        await start()
        record(record: "游戏开始")
        while true {
            await RunRound(parent: self, num: Action.mainGame!.round_num).exe()
            Action.mainGame!.round_num += 1
        }
        await end()
    }
}

//执行轮次
class RunRound: Action {
    init(parent: Action, num: Int) {
        self.num = num
        super.init(parent: parent,usetab: false)
    }
    override func exe() async {
        await start()
        await RoundStart(parent: self).exe()
        for i in 0..<Action.mainGame!.player_num {
            if Action.mainGame!.players[i].alive {
                await RunTurn(parent: self, player: i).exe()
            }
        }
        await RoundEnd(parent: self).exe()
        await end()
    }
    var num: Int
}

//轮次开始时
class RoundStart: Action {
    init(parent: Action) {
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(record: "第\((parent as! RunRound).num+1)轮开始")
        await end()
    }
}

//轮次结束时
class RoundEnd: Action {
    init(parent: Action) {
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(record: "第\((parent as! RunRound).num+1)轮结束")
        //恢复技能使用次数
        for player in Action.mainGame!.players {
            for skillGroup in player.skills {
                for skill in skillGroup.skills {
                    if skill.time_reset == .round {
                        skill.time = 0
                    }
                }
            }
        }
        await end()
    }
}

//阶段开始时
class StageStart: Action {
    init(parent: Action, player: Int, stage: Stage) {
        self.stage = stage
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(
            record: "\(getGeneralName(player: player))的\(stage.rawValue)开始"
        )
        await end()
    }
    var stage: Stage
    var player: Int
}

//阶段结束时
class StageEnd: Action {
    init(parent: Action, player: Int, stage: Stage) {
        self.stage = stage
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(
            record: "\(getGeneralName(player: player))的\(stage.rawValue)结束"
        )
        //恢复技能使用次数
        for player in Action.mainGame!.players {
            for skillGroup in player.skills {
                for skill in skillGroup.skills {
                    if skill.time_reset == .stage {
                        skill.time = 0
                    }
                }
            }
        }
        await end()
    }
    var stage: Stage
    var player: Int
}

//回合开始时
class TurnStart: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(
            record: "\(getGeneralName(player: player))的回合开始"
        )
        await end()
    }
    var player: Int
}

//回合结束时
class TurnEnd: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(
            record: "\(getGeneralName(player: player))的回合结束"
        )
        //恢复技能使用次数
        for player in Action.mainGame!.players {
            for skillGroup in player.skills {
                for skill in skillGroup.skills {
                    if skill.time_reset == .turn {
                        skill.time = 0
                    }
                }
            }
        }
        await end()
    }
    var player: Int
}

//摸牌
class DrawCard: Action {
    init(parent: Action, player: Int, num: Int) {
        self.num = num
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(record: "\(getGeneralName(player: player))从牌堆中摸了\(num)张牌")
        for _ in 0..<num {
            Action.mainGame!.set_card_position(
                index: 0,
                from: Action.mainGame!.cardList,
                to: Action.mainGame!.players[player].areas[
                    Area.HANDCARD.rawValue
                ]
            )
        }
        await end()
    }
    var num: Int
    var player: Int
}

//执行阶段
class RunStage: Action {
    init(parent: Action, player: Int, stage: Stage) {
        self.stage = stage
        self.player = player
        super.init(parent: parent,usetab: false)
    }
    override func exe() async {
        await start()
        await StageStart(parent: self, player: player, stage: stage).exe()
        switch stage {
        case .PREPARATION:
            break
        case .JUDGEMENT:
            break
        case .DRAWING:
            await DrawCard(parent: self, player: player, num: drawing_num).exe()
        case .ACTION:
            //            while !should_end {
            await ActionPoint(parent: self, player: player).exe()
        //            }
        case .DISCARD:
            break
        case .ENDING:
            break
        }
        await StageEnd(parent: self, player: player, stage: stage).exe()
        await end()
    }
    var should_end = false
    var drawing_num = 2
    var stage: Stage
    var player: Int
}

//执行回合
class RunTurn: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent,usetab: false)
    }
    override func exe() async {
        await start()
        Action.mainGame!.now_player = player
        await TurnStart(parent: self, player: player).exe()
        await RunStage(parent: self, player: player, stage: .PREPARATION).exe()
        await RunStage(parent: self, player: player, stage: .JUDGEMENT).exe()
        await RunStage(parent: self, player: player, stage: .DRAWING).exe()
        await RunStage(parent: self, player: player, stage: .ACTION).exe()
        await RunStage(parent: self, player: player, stage: .DISCARD).exe()
        await RunStage(parent: self, player: player, stage: .ENDING).exe()
        await TurnEnd(parent: self, player: player).exe()
        await end()
    }
    var player: Int
}

//体力值更改
class SetHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        let old = Action.mainGame!.players[player].health
        await start()
        record(record: "\(getGeneralName(player: player))的体力值由\(old)变为\(num)")
        Action.mainGame!.players[player].health = num
        await end()
    }
    var player: Int
    var num: Int
}

//体力上限更改
class SetMaxHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        let old = Action.mainGame!.players[player].health
        await start()
        record(record: "\(getGeneralName(player: player))的体力上限由\(old)变为\(num)")
        Action.mainGame!.players[player].max_health = num
        if getLostHealth(player: player) < 0 {
            await SetHealth(
                parent: self,
                player: player,
                num: getMaxHealth(player: player)
            ).exe()
        }
        await end()
    }
    var player: Int
    var num: Int
}

//回复体力
class Recover: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        //合法性检查
        num = min(num, getLostHealth(player: player))
        if num <= 0 {
            return
        }
        await start()
        record(record: "\(getGeneralName(player: player))回复了\(num)点体力")
        await SetHealth(
            parent: self,
            player: player,
            num: getHealth(player: player) + num
        )
        .exe()
        await end()
    }
    var player: Int
    var num: Int
}

//失去体力
class LoseHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(record: "\(getGeneralName(player: player))失去了\(num)点体力")
        await SetHealth(
            parent: self,
            player: player,
            num: getHealth(player: player) - num
        )
        .exe()
        await end()
    }
    var player: Int
    var num: Int
}

//增加体力上限
class AddMaxHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(record: "\(getGeneralName(player: player))增加了\(num)点体力上限")
        await SetMaxHealth(
            parent: self,
            player: player,
            num: getMaxHealth(player: player) + num
        )
        .exe()
        await end()
    }
    var player: Int
    var num: Int
}

//减少体力上限
class ReduceMaxHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record(record: "\(getGeneralName(player: player))减少了\(num)点体力上限")
        await SetMaxHealth(
            parent: self,
            player: player,
            num: getMaxHealth(player: player) - num
        )
        .exe()
        await end()
    }
    var player: Int
    var num: Int
}

//出牌阶段空闲时间点
class ActionPoint: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent, usetab: false)
    }
    override func exe() async {
        await start()
        //        let response = await Choosing(
        //            parent: self,
        //            player: self.player,
        //            choses: [("结束出牌", 0)]
        //        ).exe()
        //        if let res = response as? Int {
        //            if res == 0 {
        //                (self.parent as! Stage).should_end = true
        //            }
        //        }
        await end()
    }
    var player: Int
}

//技能轮询
class AskSkill: Action {
    init(parent: Action) {
        super.init(parent: parent, usetab: false)
    }
    override func exe() async {
        for i in Action.mainGame!.players.indices {
            //检测角色是否存活
            let player =
            Action.mainGame!.players[(i + Action.mainGame!.now_player) % Action.mainGame!.player_num] //从当前回合角色开始
            if isAlive(player: player.seat){
                while true {
                    var skls:[Skill] = []
                    for skillGroup in player.skills{
                        for skill in skillGroup.skills {
                            if await skill
                                .can_use(skill, parent!, player.seat) {
                                //锁定技直接发动
                                if skill.locked{
                                    await skill.exe(skill,parent!, player.seat)
                                    continue
                                }
                                //非锁定技加入选择列表
                                skls.append(skill)
                            }
                        }
                    }
                    var choses:[(String,Int)] = []
                    for i in skls.indices{
                        choses.append((skls[i].name,i))
                    }
                    if choses.isEmpty{
                        break
                    }
                    choses.append(("取消",-1))
                    let response = await Choosing(
                        parent: parent!,
                        text: "发动技能",
                        player: player.seat,
                        choses: choses
                    ).exe()
                    if response is Int {
                        if (response as! Int) == -1 {
                            break
                        }
                        else{
                            await skls[response as! Int].exe(skls[response as! Int],parent!, player.seat)
                        }
                    }
                }
            }

        }
    }
}

//辅助函数

//进行选择
class Choosing {
    init(
        parent: Action,
        text: String = "",
        player: Int,
        choses: [(String, Int)]
    ) {
        self.text = text
        self.player = player
        self.choses = choses
    }

    func exe() async -> Any {
        let chose = Chose(
            parent: self,
            text: text,
            player: player,
            choses: choses
        )
        Action.mainGame!.chooses.insert(chose, at: 0)
        await withCheckedContinuation { continuation in
            chose.continuation = continuation
        }
        return chosed!
    }

    var text: String
    var player: Int
    var choses: [(String, Int)]
    var chosed: Int?
}

//获取体力值
func getHealth(player: Int) -> Int {
    let player = Action.mainGame!.players[player]
    return player.health
}

//获取体力上限
func getMaxHealth(player: Int) -> Int {
    let player = Action.mainGame!.players[player]
    return player.max_health
}

//获取已损失体力值
func getLostHealth(player: Int) -> Int {
    return getMaxHealth(player: player) - getHealth(player: player)
}

//获取是否已受伤
func isHurted(player: Int) -> Bool {
    if getLostHealth(player: player) > 0 {
        return true
    } else {
        return false
    }
}

//获取是否存活
func isAlive(player: Int) -> Bool {
    return Action.mainGame!.players[player].alive
}

//获取武将名称
func getGeneralName(player: Int) -> String {
    let player = Action.mainGame!.players[player]
    return player.general.name
}

//选择
class Chose {
    init(parent: Choosing, text: String, player: Int, choses: [(String, Int)]) {
        self.parent = parent
        self.text = text
        self.player = player
        self.choses = choses
    }
    func choose(chosed: Int) {
        parent.chosed = chosed
        finished = true
        continuation?.resume(returning: ())
    }
    var continuation: CheckedContinuation<Void, Never>?
    var parent: Choosing
    var text: String
    var player: Int
    var choses: [(String, Int)]
    var finished: Bool = false
}
