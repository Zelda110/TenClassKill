//
//  actions.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.04.13.
//

import Foundation

//遊戲行為
class Action {
    init(parent: Action?, usetab: Bool = true) {
        self.parent = parent
        self.use_tab = usetab
    }
    func exe() async {

    }

    //自動操作
    func start() async {
        if use_tab {
            Action.tabs += 1
        }
        try? await Task.sleep(nanoseconds: 10_000_000_0)
    }
    func end() async {
        if use_tab {
            Action.tabs -= 1
        }
        try? await Task.sleep(nanoseconds: 10_000_000_0)
    }

    static var tabs = 0  //記錄層級
    static var mainGame: MainGame? = nil  //主遊戲
    var parent: Action?  //父行為
    var use_tab: Bool  //是否使用縮進
    //技能輪詢
    func askSkill() async {
        for i in 0...(Action.mainGame!.playerNum - 1) {
            let player =
                (i + Action.mainGame!.nowPlayer) % Action.mainGame!.playerNum
            if isAlive(player: player) {
                await getPlayer(player).askPlayerSkill(parent: self)
            }
        }
    }
    //添加記錄
    func record(_ record: String) {
        Action.mainGame!.records
            .insert(
                Record(
                    record: record,
                    tabs: Action.tabs,
                    self_id: Record.id
                ),
                at: 0
            )
        Record.id += 1
        if DEBUG_MODE {
            print(record)
        }
    }
}

//遊戲開始時
class GameStart: Action {
    override func exe() async {
        await start()
        record("遊戲開始")
        await askSkill()
        while true {
            await RunRound(parent: self, num: Action.mainGame!.roundNum).exe()
            Action.mainGame!.roundNum += 1
        }
        await end()
    }
}

//執行輪次
class RunRound: Action {
    init(parent: Action, num: Int) {
        self.num = num
        super.init(parent: parent, usetab: false)
    }
    override func exe() async {
        await start()
        await RoundStart(parent: self).exe()
        for i in 0..<Action.mainGame!.playerNum {
            if Action.mainGame!.players[i].alive {
                await RunTurn(parent: self, player: i).exe()
            }
        }
        await RoundEnd(parent: self).exe()
        await end()
    }
    var num: Int
}

//輪次開始時
class RoundStart: Action {
    init(parent: Action) {
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("第\((parent as! RunRound).num+1)輪開始")
        await askSkill()
        await end()
    }
}

//輪次結束時
class RoundEnd: Action {
    init(parent: Action) {
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("第\((parent as! RunRound).num+1)輪結束")
        await askSkill()
        //恢復技能使用次數
        for player in Action.mainGame!.players {
            for skillGroup in player.skills {
                for skill in skillGroup.skills {
                    if skill.timeReset == .round {
                        skill.time = 0
                    }
                }
            }
        }
        await end()
    }
}

//階段開始時
class StageStart: Action {
    init(parent: Action, player: Int, stage: Stage) {
        self.stage = stage
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))的\(stage.rawValue)開始")
        await askSkill()
        await end()
    }
    var stage: Stage
    var player: Int
}

//階段結束時
class StageEnd: Action {
    init(parent: Action, player: Int, stage: Stage) {
        self.stage = stage
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))的\(stage.rawValue)結束")
        await askSkill()
        //恢復技能使用次數
        for player in Action.mainGame!.players {
            for skillGroup in player.skills {
                for skill in skillGroup.skills {
                    if skill.timeReset == .stage {
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

//回合開始時
class TurnStart: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))的回合開始")
        await askSkill()
        await end()
    }
    var player: Int
}

//回合結束時
class TurnEnd: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))的回合結束")
        await askSkill()
        //恢復技能使用次數
        for player in Action.mainGame!.players {
            for skillGroup in player.skills {
                for skill in skillGroup.skills {
                    if skill.timeReset == .turn {
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
        record("\(getGeneralName(player: player))從牌堆中摸了\(num)張牌")
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

//執行階段
class RunStage: Action {
    init(parent: Action, player: Int, stage: Stage) {
        self.stage = stage
        self.player = player
        super.init(parent: parent, usetab: false)
    }
    override func exe() async {
        await start()
        await StageStart(parent: self, player: player, stage: stage).exe()
        switch stage {
        case .PREPARATION:
            await askSkill()
        case .JUDGEMENT:
            await askSkill()
        case .DRAWING:
            await askSkill()
        case .ACTION:
            //                        while !should_end {
            await ActionPoint(parent: self, player: player).exe()
        //                    }
        case .DISCARD:
            await askSkill()
        case .ENDING:
            await askSkill()
        }
        await StageEnd(parent: self, player: player, stage: stage).exe()
        await end()
    }
    var should_end = false
    var drawing_num = 2
    var stage: Stage
    var player: Int
}

//執行回合
class RunTurn: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent, usetab: false)
    }
    override func exe() async {
        await start()
        Action.mainGame!.nowPlayer = player
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

//體力值更改
class SetHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        let old = Action.mainGame!.players[player].health
        await start()
        record("\(getGeneralName(player: player))的體力值由\(old)變為\(num)")
        Action.mainGame!.players[player].health = num
        await askSkill()
        await end()
    }
    var player: Int
    var num: Int
}

//體力上限更改
class SetMaxHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        let old = Action.mainGame!.players[player].health
        await start()
        record("\(getGeneralName(player: player))的體力上限由\(old)變為\(num)")
        Action.mainGame!.players[player].max_health = num
        if getLostHealth(player: player) < 0 {
            await SetHealth(
                parent: self,
                player: player,
                num: getMaxHealth(player: player)
            ).exe()
        }
        await askSkill()
        await end()
    }
    var player: Int
    var num: Int
}

//回復體力
class Recover: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        //合法性檢查
        num = min(num, getLostHealth(player: player))
        if num <= 0 {
            return
        }
        await start()
        record("\(getGeneralName(player: player))回復了\(num)點體力")
        await SetHealth(
            parent: self,
            player: player,
            num: getHealth(player: player) + num
        )
        .exe()
        await askSkill()
        await end()
    }
    var player: Int
    var num: Int
}

//失去體力
class LoseHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))失去了\(num)點體力")
        await SetHealth(
            parent: self,
            player: player,
            num: getHealth(player: player) - num
        )
        .exe()
        await askSkill()
        await end()
    }
    var player: Int
    var num: Int
}

//增加體力上限
class AddMaxHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))增加了\(num)點體力上限")
        await SetMaxHealth(
            parent: self,
            player: player,
            num: getMaxHealth(player: player) + num
        )
        .exe()
        await askSkill()
        await end()
    }
    var player: Int
    var num: Int
}

//減少體力上限
class ReduceMaxHealth: Action {
    init(parent: Action, player: Int, num: Int) {
        self.player = player
        self.num = num
        super.init(parent: parent)
    }
    override func exe() async {
        await start()
        record("\(getGeneralName(player: player))減少了\(num)點體力上限")
        await SetMaxHealth(
            parent: self,
            player: player,
            num: getMaxHealth(player: player) - num
        )
        .exe()
        await askSkill()
        await end()
    }
    var player: Int
    var num: Int
}

//出牌階段空閒時間點
class ActionPoint: Action {
    init(parent: Action, player: Int) {
        self.player = player
        super.init(parent: parent, usetab: false)
    }
    override func exe() async {
        await start()
        await askSkill()
        await end()
    }
    var player: Int
}

//用戶選擇
class Option {
    init(name: String, value: Int) {
        self.type = .common
        self.name = name
        self.value = value
    }
    init(card: GameCard) {
        self.type = .card
        self.name = ""
        self.value = card.id
    }
    init(skill: Skill) {
        self.type = .skill
        self.name = skill.name
        self.value = skill.id
    }
    var type: OptionType
    var name: String
    var value: Int
    var hash: Int {
        self.name.hashValue ^ self.value.hashValue
    }
}

class Choice {
    init(
        continuation: CheckedContinuation<(OptionType, Int), Never>,
        options: [Option],
        player: Int
    ) {
        self.continuation = continuation
        self.options = options
        self.player = player
    }
    var continuation: CheckedContinuation<(OptionType, Int), Never>
    var options: [Option]
    var player: Int

    func choose(choosedOption: Option) {
        continuation.resume(returning: (choosedOption.type, choosedOption.value))
        Action.mainGame!.nowChoice = nil
    }
}

//輔助函數

func getPlayer(_ seat: Int) -> Player {
    return Action.mainGame!.players[seat]
}

//獲取體力值
func getHealth(player: Int) -> Int {
    return getPlayer(player).health
}

//獲取體力上限
func getMaxHealth(player: Int) -> Int {
    return getPlayer(player).max_health
}

//獲取已損失體力值
func getLostHealth(player: Int) -> Int {
    return getMaxHealth(player: player) - getHealth(player: player)
}

//獲取是否已受傷
func isHurted(player: Int) -> Bool {
    if getLostHealth(player: player) > 0 {
        return true
    } else {
        return false
    }
}

//獲取是否存活
func isAlive(player: Int) -> Bool {
    return getPlayer(player).alive
}
func isAlive(player: Player) -> Bool {
    return player.alive
}

//獲取武將名稱
func getGeneralName(player: Int) -> String {
    return getPlayer(player).general.name
}
