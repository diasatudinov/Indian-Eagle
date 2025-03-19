//
//  TransparentSpriteView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI
import SpriteKit


struct SpriteViewContainer: UIViewRepresentable {
    let scene: SKScene
    
    func makeUIView(context: Context) -> SKView {
        // Устанавливаем фрейм равным размеру экрана
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .clear
        // Гибкое изменение размеров
        
        // Настраиваем сцену
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Обновляем размер SKView при изменении размеров SwiftUI представления
        uiView.frame = UIScreen.main.bounds
    }
}

#Preview {
    BirdsGameView(difficulty: .easy)
}
