//
//  gamelogic.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.09.
//

import Foundation

func log(_ msg: String, _ importance: Int = 0) {
    print(msg)
}

//遊戲類
class MainGame {
    init(player_num: Int) {
        self.player_num = player_num
        Action.mainGame = self
        players = [
            Player(general: WCY, seat: 0),
            Player(general: LQE, seat: 1),
            Player(general: LCY, seat: 2),
        ]
        generate_cardlist()
        giving_intital_card()
        log("Game Inited")
    }

    //開始遊戲
    func start() async {
        notifyChange()
        Action.mainGame = self
        let gameStart = GameStart(parent: nil)  //開始遊戲操作
        self.now_action = gameStart
        Task{
            while true{
                Action.mainGame!.notifyChange()
                try? await Task.sleep(nanoseconds: 10_000_000)
            }
        }
        await gameStart.exe()
    }

    //生成牌堆
    func generate_cardlist() {
        for _ in 0...13 {
            for i in 1...13 {
                cardList.add_card(
                    card: Card(
                        suit: .HEARTS,
                        number: i,
                        name: .桃
                    )
                )
            }
        }
    }

    //發初始手牌
    func giving_intital_card() {
        for _ in 0...3 {
            for player in players {
                set_card_position(
                    index: 0,
                    from: cardList,
                    to: player.areas[Area.HANDCARD.rawValue]
                )
            }
        }
    }

    let player_num: Int  //人數
    var players: [Player] = []
    var round_num = 0  //輪次
    var now_player = 0 //當前回合角色
    var cardList = CardList()  //牌堆
    var discardedList = CardList()  //棄牌堆
    var dealingList = CardList()  //處理區
    var records: [Record] = []  //記錄
    var now_action: Action = GameStart(parent: nil) //當前操作
    
    //與ViewModel通信
    var onStateChange: (()->Void)?
    func notifyChange(){
        DispatchQueue.main.async{
            self.onStateChange?()
        }
    }

    //設置體力
    func set_health(player: Int, num: Int) {
        players[player].health = num
    }
    //設置體力上限
    func set_max_health(player: Int, num: Int) {
        players[player].max_health = num
    }
    //改變牌位置
    func set_card_position(id: Int, from: CardList, to: CardList) {
        guard let card = from.search_for_card(id: id) else {
            log("failed to move card, id:\(id)", 3)
            return
        }
        let _ = from.remove_card(id: id)
        to.add_card(card: card.0)
    }
    func set_card_position(index: Int, from: CardList, to: CardList) {
        if (0..<from.cardlist.count).contains(index) {
            let card = from.cardlist[index]
            let _ = from.remove_card(id: card.id)
            to.add_card(card: card)
        } else {
            log("failed to move card, index:\(index)", 3)
            return
        }
    }
}

//玩家類
class Player {
    init(general: General, seat: Int) {
        self.general = general
        self.health = general.health
        self.max_health = general.max_health
        self.shield = general.shield
        self.skills = general.skills
        self.subject = general.subject
        self.seat = seat
    }

    //武將
    var general: General
    //區域
    var areas: [CardList] = [CardList(), CardList(), CardList()]
    //體力值
    var health: Int
    var max_health: Int
    var shield: Int
    //技能
    var skills: [SkillGroup]
    //勢力
    var subject: Subject
    //座次
    var seat: Int
    //是否存活
    var alive = true
}

//卡牌列表
class CardList {
    var cardlist: [Card] = []
    //以id搜尋卡牌，返回卡牌和索引
    func search_for_card(id: Int) -> (Card, Int)? {
        for i in cardlist.indices {
            if cardlist[i].id == id {
                return (cardlist[i], i)
            }
        }
        return nil
    }
    //添加卡牌
    func add_card(card: Card) {
        cardlist.append(card)
    }
    //移除卡牌，返回0表示成功，返回1表示無該牌
    func remove_card(id: Int) -> Int {
        if let index = search_for_card(id: id) {
            cardlist.remove(at: index.1)
            return 0
        }
        return 1
    }
}

//遊戲記錄
struct Record {
    var record: String
    var tabs: Int
    var self_id: Int
    static var id = 0
}
