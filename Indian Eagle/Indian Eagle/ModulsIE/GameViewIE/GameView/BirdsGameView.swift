//
//  BirdsGameView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI
import SpriteKit

struct BirdsGameView: View {
    @State var difficulty: Difficulty
    var scene: SKScene {
        // Создаём сцену, можно менять размер, масштаб и уровень сложности
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        // Установите уровень сложности: .easy, .medium или .hard
        scene.difficulty = difficulty
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }.background(
            ZStack {
                Image(.appBgIE)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
            }
            
        )
    }
}

#Preview {
    BirdsGameView(difficulty: .easy)
}
