struct TransparentSpriteView: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = true
        skView.isOpaque = false
        skView.backgroundColor = .clear
        
        // Настройка сцены
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        skView.presentScene(scene)
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Если нужно обновлять сцену, можно здесь это сделать
    }
}