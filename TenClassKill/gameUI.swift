//
//  gameUI.swift
//  TenthClassKill
//
//  Created by ハイラル・ゼルダ on 2025.03.02.
//

import GateEngine

//鼠標信息
struct MouseState {
    var x: Float = 0
    var y: Float = 0
}

@main
//遊戲UI主程序
final class GameUI: GameDelegate {

    //初始化代碼
    func didFinishLaunching(game: Game, options: LaunchOptions) async {

        game.insertSystem(Drawing.self)

        game.insertSystem(Updating.self)

        game.windowManager.mainWindow?.title = "War of the 10th Class"
    }
}

final class TextComponent: Component {

    @MainActor
    let text = Text(string: "Hello World!", pointSize: 64, color: .white)

    static let componentID: ComponentID = ComponentID()
}

//更新系統
final class Updating: System {
    
    //鼠標信息
    var mousestate = MouseState()

    //獲取用戶輸入
    var inputReceipts = InputReceipts()

    //系統初始化
    override func setup(game: Game, input: HID) async {

        let entity = Entity()

        entity.insert(TextComponent.self)

        game.insertEntity(entity)
    }

    //處理輸入
    override func update(
        game: Game, input: HID, withTimePassed deltaTime: Float
    ) async {
        if let entity = game.firstEntity(withComponent: TextComponent.self) {
            entity.modify(TextComponent.self) { [self] component in
                //鼠標輸入
                if input.mouse.position != nil {
                    mousestate.x=input.mouse.position!.x
                    mousestate.y=input.mouse.position!.y
                }
            }
        }
    }

    override class var phase: System.Phase { .simulation }
}

//渲染系統
class Drawing: RenderingSystem {
    override func render(
        game: Game,
        window: Window,
        withTimePassed deltaTime: Float
    ) {
        //創建當前幀畫布
        var canvas = Canvas()
        
        //依次處理實體
        for entity in game.entities {
            guard let text = entity.component(ofType: TextComponent.self)?.text
            else { continue }
            let windowCenter = Rect(size: window.size).center
            let halfTextSize = text.size / 2
            let position = windowCenter - halfTextSize
            canvas.insert(text, at: position)
        }

        //將畫面投到窗口
        window.insert(canvas)
    }
}
