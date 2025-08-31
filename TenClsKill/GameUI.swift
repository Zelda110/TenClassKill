//
//  GameUI.swift
//  TenClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.30.
//

import Combine
import SwiftUI

#if (DEBUG)
    let DEBUG_MODE: Bool = true
#else
    let DEBUG_MODE: Bool = false
#endif

#if os(macOS)
let card_scale = 0.1
#elseif os(iOS)
let card_scale = 0.08
#endif
let general_card_width = 1094 * card_scale
let general_card_height = 1534 * card_scale + 180 * card_scale
let game_card_width = 1024 * card_scale
let game_card_height = 1438 * card_scale

//主遊戲的視圖模型
@MainActor
class GameViewModel: ObservableObject {
    let player_num = 3
    @Published var players: [Player] = []
    @Published var round_num = 0  //輪次
    @Published var now_player = 0  //當前回合玩家
    @Published var operating_player: Int = 0  //本機操作玩家
    @Published var cardList = CardList()  //牌堆
    @Published var discardedList = CardList()  //棄牌堆
    @Published var dealingList = CardList()  //處理區
    @Published var records: [Record] = []  //記錄
    @Published var now_action: Action = GameStart(parent: nil)  //當前操作
    @Published var handcards: [[GameCard]] = []  //手牌
    @Published var nowChoice: Choice? = nil  //當前選擇

    var game = MainGame(player_num: 3)

    init() {
        self.players = self.game.players
        self.round_num = self.game.roundNum
        self.now_player = self.game.nowPlayer
        self.cardList = self.game.cardList
        self.discardedList = self.game.discardedList
        self.dealingList = self.game.dealingList
        self.records = self.game.records
        self.now_action = self.game.nowAction
        self.nowChoice = self.game.nowChoice
        for player in players {
            self.handcards.append(player.areas[Area.HANDCARD.rawValue].cardlist)
        }

        game.onStateChange = { [weak self] in
            guard let self else { return }
            self.players = self.game.players
            self.round_num = self.game.roundNum
            self.now_player = self.game.nowPlayer
            self.cardList = self.game.cardList
            self.discardedList = self.game.discardedList
            self.dealingList = self.game.dealingList
            self.records = self.game.records
            self.now_action = self.game.nowAction
            self.nowChoice = self.game.nowChoice
            self.handcards = []
            for player in players {
                self.handcards.append(
                    player.areas[Area.HANDCARD.rawValue].cardlist
                )
            }
        }
        game.notifyChange()
    }

}

//主遊戲
struct GameUI: View {
    var body: some View {
        InGameUI()
    }
}

//遊戲界面
struct InGameUI: View {
    @State var view_record = false
    @StateObject var game = GameViewModel()
    var body: some View {
        GeometryReader { geo in
            //遊戲主界面
            ZStack {
                VStack {
                    Spacer()
                    //選擇介面
                    ChoiceUI(game: game)
                    //手牌
                    HStack {
                        CardListUI(
                            cardlist: game.handcards[game.operating_player],
                            width: geo.size.width - 2 * general_card_width,
                            isHandCard: true,
                            game: game
                        )
                        .padding(.vertical, 100 * card_scale)
                        Spacer()
                    }
                }.frame(width: min(geo.size.width - 2 * general_card_width,0))
                //武將牌
                ZStack {
                    ForEach(game.players, id: \.seat) { i in
                        GeneralCardUI(
                            player: i,
                            game: game
                        )
                    }
                }
                //牌堆
                HStack {
                    Spacer()
                    VStack {
                        CardListUI(
                            cardlist: game.cardList.cardlist,
                            back_up: true,
                            width: game_card_width,
                            scrollable: false,
                            game: game
                        )
                        Text(String(game.cardList.cardlist.count))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                //處理區
                CardListUI(
                    cardlist: game.dealingList.cardlist,
                    width: game_card_width * Double(game.dealingList.cardlist.count),
                    scrollable: false,
                    isHandCard: false,
                    game: game
                )
            }
            //記錄顯示
            if view_record {
                RecordUI(view_record: $view_record, game: game)
            }
            //功能按鈕
            VStack {
                Spacer()
                HStack {
                    Button("記錄") {
                        withAnimation {
                            view_record = !view_record
                        }
                    }.keyboardShortcut("r", modifiers: [])
                    if DEBUG_MODE {
                        Picker("操控玩家", selection: $game.operating_player) {
                            ForEach(0..<game.player_num, id: \.self) { i in
                                Text(String(i + 1)).tag(i)
                            }
                        }
                        .frame(maxWidth: 100.0)
                    }
                    Spacer()
                }
            }
        }
        #if os(macOS)
            .frame(minWidth: 800, minHeight: 450)
        #endif
        .background(alignment: .center) {
            Image("bg")
                .resizable()
                .ignoresSafeArea()
                .aspectRatio(contentMode: .fill)
        }  //背景圖片
        .onAppear {
            Task.detached {
                await game.game.start()
            }
        }  //遊戲主進程
    }
}

func getVerticalName(name: String) -> String {
    var out: String = ""
    for i in name {
        out += String(i)
        out += "\n"
    }
    return out

}

//武將牌UI
struct GeneralCardUI: View {
    var player: Player
    @ObservedObject var game: GameViewModel
    var body: some View {
        let card_id = player.general.get_image()
        let relative_num = player.seat - game.operating_player
        let name = getVerticalName(name: player.general.name)
        GeometryReader { geo in
            VStack {
                ZStack(alignment: .leading) {
                    //原畫
                    Image("\(card_id)")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    ZStack(alignment: .top) {
                        //側邊欄
                        Rectangle()
                            .foregroundColor(Color(player.subject.rawValue))
                        VStack {
                            //勢力標記
                            Image(player.subject.rawValue)
                                .resizable()
                                .scaledToFit()
                            //姓名
                            Text(name)
                                .foregroundStyle(.white)
                                .shadow(radius: 10)
                                .font(.system(size: 13))
                            Spacer(minLength: 0)
                            //體力值
                            VStack(spacing: 0) {
                                let health = player.health
                                let max_health = player.max_health
                                let shield = player.shield
                                //圖形顯示
                                if shield + max_health <= 5 && health >= 0 {
                                    //體力
                                    ForEach(
                                        0..<shield,
                                        id: \.self
                                    ) { _ in
                                        Image("shield")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    ForEach(
                                        0..<(max_health - health),
                                        id: \.self
                                    ) { _ in
                                        Image("health_air")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    ForEach(
                                        0..<health,
                                        id: \.self
                                    ) { _ in
                                        Image("health")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                //文字顯示
                                else {
                                    Text(
                                        String(health)
                                    )
                                    .font(.system(size: 9))
                                    Text("/")
                                        .font(.system(size: 8))
                                    Text(String(max_health))
                                        .font(.system(size: 9))
                                    if shield > 0 {
                                        Text("+")
                                            .font(.system(size: 10))
                                        Text(String(shield))
                                            .font(.system(size: 9))
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: 0.13 * general_card_width)
                }
                .cornerRadius(5)
                VStack {
                    //座次
                    Text("\(player.seat+1)號位")
                        .foregroundColor(.white)
                        .font(.system(size: 13))
                        .shadow(radius: 10)
                }
            }
            .frame(
                width: general_card_width,
                height: general_card_height,
                alignment: .center
            )
            .position(
                getGeneralUiPosition(
                    game: game,
                    geo: geo,
                    index: relative_num
                )
            )
            .animation(.default, value: game.operating_player)
        }
    }
}

//獲取各玩家武將排列位置
func getGeneralUiPosition(game: GameViewModel, geo: GeometryProxy, index: Int)
    -> CGPoint
{
    var index = index
    if index < 0 {
        index += game.player_num
    }
    let l1 = max(Double(geo.size.height - general_card_height), 0)  //右
    let l2 = max(Double(geo.size.width - general_card_width), 0)  //上
    let l3 = Double(geo.size.height)  //左
    let dl = (l1 + l2 + l3) / Double(game.player_num)  //兩張牌間的差值
    let cx: Double
    let cy: Double
    if Double(index) * dl <= l1 {
        cx = geo.size.width - general_card_width / 2
        cy = geo.size.height - general_card_height / 2 - Double(index) * dl
    } else if (l1...(l1 + l2)).contains(Double(index) * dl) {
        let rl = Double(index) * dl - l1
        cx = geo.size.width - general_card_width / 2 - rl
        cy = general_card_height / 2
    } else {
        let rl = Double(index) * dl - l1 - l2
        cx = general_card_width / 2
        cy = general_card_height / 2 + rl
    }
    return CGPoint(x: cx, y: cy)
}

//遊戲牌UI
struct GameCardUI: View {
    var card: GameCard
    var back_up = false  //是否背面朝上
    var body: some View {
        ZStack {
            //圖片
            Image(back_up ? "card_bg" : "\(card.cardName.image)")
                .resizable()
            //花色點數
            if !back_up {
                HStack {
                    VStack(spacing: 0) {
                        Text("\(Nunber[card.number])")
                            .foregroundColor(getSuitColor(suit: card.suit))
                            .font(.system(size: 150*card_scale))
                        Image(card.suit.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120 * card_scale)
                        Spacer()
                    }
                    Spacer()
                }.padding(.horizontal, 80*card_scale)
                    .padding(.vertical, 50*card_scale)
            }
        }
        .frame(
            width: game_card_width,
            height: game_card_height,
            alignment: .center
        )
        .cornerRadius(5)
    }
}

//牌列表UI
struct CardListUI: View {
    var cardlist: [GameCard]
    var back_up = false  //是否背面朝上
    var width: Double
    var scrollable: Bool = true  //是否可以滾動
    var isHandCard: Bool = false  //是否是手牌
    @ObservedObject var game: GameViewModel

    func canUse(card: GameCard) -> Bool {
        if let choice = game.nowChoice {
            if choice.player == game.operating_player {
                for option in choice.options {
                    if option.type == .card && option.value == card.id {
                        return true
                    }
                }
            }
        }
        return false
    }
    func getBright(card: GameCard) -> Double {
        if isHandCard {
            return canUse(card: card) ? 0 : -0.5
        }
        return 0
    }

    var body: some View {
        if scrollable {
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(
                        cardlist,
                        id: \.id
                    ) { card in
                        GameCardUI(card: card, back_up: back_up)
                            .brightness(getBright(card: card))
                            .onTapGesture {
                                if canUse(card: card) {
                                    game.nowChoice!
                                        .choose(
                                            choosedOption: Option(card: card)
                                        )
                                }
                            }
                    }
                }
            }.frame(width: max(width, 0))
        } else {
            HStack(spacing: 0) {
                ForEach(
                    cardlist,
                    id: \.id
                ) { card in
                    GameCardUI(card: card, back_up: back_up)
                }
            }
            .frame(width: max(width, 0), alignment: .leading)
            .clipped()

        }
    }
}

//顯示記錄界面
struct RecordUI: View {
    @Binding var view_record: Bool
    @ObservedObject var game: GameViewModel
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(game.records, id: \.self_id) { record in
                        Text(
                            String(repeating: "      ", count: record.tabs - 1)
                                + record.record
                        )
                        .font(.system(size: 15))
                    }
                }.padding()
                Spacer()
            }
        }
        .background(.ultraThinMaterial)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: game.records.count)
    }
}

//選項介面
struct OptionUI: View {
    var option: Option
    @ObservedObject var game: GameViewModel
    var body: some View {
        Button(option.name) {
            game.nowChoice!.choose(choosedOption: option)
        }
    }
}

//選擇欄介面
struct ChoiceUI: View {
    @ObservedObject var game: GameViewModel
    var body: some View {
        HStack {
            if let choice = game.nowChoice {
                if choice.player == game.operating_player {
                    ForEach(choice.options, id: \.hashValue) { option in
                        if option.type != .card {
                            OptionUI(option: option, game: game)
                        }
                    }
                }
            }
        }
    }
}

//預覽
struct GameUI_Previews: PreviewProvider {
    static var previews: some View {
        GameUI()
    }
}
