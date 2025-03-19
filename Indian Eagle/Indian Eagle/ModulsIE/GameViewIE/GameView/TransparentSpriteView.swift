//
//  TransparentSpriteView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI
import SpriteKit


struct SpriteViewContainer: UIViewRepresentable {
    @StateObject var user = IEUser.shared
    var scene: GameScene
    @Binding var gameWin: Bool
    @Binding var moves: Int
    @State var difficulty: Difficulty
    func makeUIView(context: Context) -> SKView {
        // Устанавливаем фрейм равным размеру экрана
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .clear
        // Настраиваем сцену
        scene.scaleMode = .resizeFill
        scene.winHandler = {
            user.updateUserBirds(for: 100)
            user.updateUserStars(for: 5)
            gameWin = true
        }
        scene.movesHandler = {
            moves += 1
        }
        scene.difficulty = difficulty
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Обновляем размер SKView при изменении размеров SwiftUI представления
        uiView.frame = UIScreen.main.bounds
    }
}

#Preview {
    BirdsGameView(difficulty: .hard)
}
