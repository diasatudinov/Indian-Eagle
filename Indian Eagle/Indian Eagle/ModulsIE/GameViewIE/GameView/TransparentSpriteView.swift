//
//  TransparentSpriteView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI
import SpriteKit

struct TransparentSpriteView: UIViewRepresentable {
    let scene: GameScene
    var skView: SKView
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        // Настройка сцены
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        skView.presentScene(scene)
        skView.backgroundColor = .clear
        skView.ignoresSiblingOrder = true
        skView.backgroundColor = .clear
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Если нужно обновлять сцену, можно здесь это сделать
    }
}

//struct GameSceneView: UIViewRepresentable {
//    @StateObject var user = User.shared
//    @StateObject var teamVM: TeamViewModel
//    @Binding var coinsCount: Int
//    @Binding var starsCount: Int
//    var delegate: GameSceneDelegate?
//    var skView: SKView
//    var gameScene: GameScene
//    @Binding var gameOver: Bool
//    func makeUIView(context: Context) -> SKView {
//        let skView = SKView()
//        let scene = gameScene
//        scene.scaleMode = .resizeFill
//        scene.gameOverHandler = {
//            gameOver = true
//            user.updateUserCoins(for: coinsCount + starsCount)
//            teamVM.addScore(points: coinsCount + starsCount)
//            print("added \(coinsCount + starsCount) coins")
//        }
//        scene.coinsUpdateHandler = {
//            coinsCount += 1
//        }
//        
//        scene.starsUpdateHandler = {
//            starsCount += 1
//        }
//        skView.presentScene(scene)
//        skView.ignoresSiblingOrder = true
//        skView.backgroundColor = .clear
//        return skView
//    }
//    
//    func updateUIView(_ uiView: SKView, context: Context) {
//        //
//    }
//    
//
//}
