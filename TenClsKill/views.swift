//
//  views.swift
//  tencls-kill
//
//  Created by ハイラル・ゼルダ on 2025/5/31.
//

import SwiftUI

struct GeneralView: View {
    var general: General
    var body: some View {
        let card_id = general.get_image()
        let name = getVerticalName(name: general.name)
        HStack {
            ZStack(alignment: .leading) {
                //原畫
                Image("\(card_id)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                ZStack(alignment: .top) {
                    //側邊欄
                    Rectangle()
                        .foregroundColor(Color(general.subject.rawValue))
                    VStack {
                        //勢力標記
                        Image(general.subject.rawValue)
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
                            let health = general.health
                            let max_health = general.max_health
                            let shield = general.shield
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
                }.frame(width: 0.13 * general_card_width)
            }
            .cornerRadius(5)
            .frame(
                width: general_card_width,
                height: general_card_height - 180 * card_scale,
                alignment: .center
            )
            VStack(alignment: .leading) {
                HStack {
                    Text(general.name)
                    Text(getSubjectName(sub: general.subject))
                    Text(general.gender.rawValue)
                }
                .padding(.vertical, 5)
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(general.skills, id: \.name) { skillGroup in
                        VStack(alignment: .leading) {
                            Text(skillGroup.name)
                                .font(.title3)
                            Text(skillGroup.description)
                        }
                    }
                }
            }.padding()
        }
    }
}

#Preview {
    GeneralView(general: WCY)
}
