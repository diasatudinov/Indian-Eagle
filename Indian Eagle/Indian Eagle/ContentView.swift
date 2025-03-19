import SwiftUI
import SpriteKit

struct ContentView: View {
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
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}






#Preview {
    ContentView(difficulty: .easy)
}
