import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        // Создаём сцену, можно менять размер, масштаб и уровень сложности
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        // Установите уровень сложности: .easy, .medium или .hard
        scene.difficulty = .easy
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

// MARK: - Основная игровая сцена

class GameScene: SKScene {
    enum Difficulty {
        case easy, medium, hard
    }
    
    var difficulty: Difficulty = .easy
    
    // Параметры игры
    var branchCount: Int = 4
    var birdColors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.green]
    var maxMoves: Int = 0  // Для сложного уровня
    
    // Массив веток (каждая ветка – это SKNode)
    var branches: [SKNode] = []
    
    // Выбранная птица для перемещения
    var selectedBird: SKSpriteNode?
    
    // Счётчик ходов (для сложного уровня)
    var movesMade: Int = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        // Настройка параметров сложности
        switch difficulty {
        case .easy:
            // Лёгкий уровень: веток может быть 3 или 4.
            branchCount = Int.random(in: 3...4)
            // Если веток 3, то два типа птиц, если 4 – три типа.
            if branchCount == 3 {
                birdColors = [UIColor.red, UIColor.blue]   // 2 цвета
            } else {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green]  // 3 цвета
            }
            maxMoves = 0  // Без ограничения ходов
        case .medium:
            branchCount = Int.random(in: 5...6)
            birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
            maxMoves = 0
        case .hard:
            branchCount = Int.random(in: 6...7)
            birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple, UIColor.orange]
            maxMoves = 20
        }
        
        createBranches()
    }
    
    // Создание веток и заполнение птицами
    func createBranches() {
        // Удаляем старые ветки
        for branch in branches {
            branch.removeFromParent()
        }
        branches.removeAll()
        
        // Создаём ветки и располагаем их по вертикали
        let branchSpacing = size.height / CGFloat(branchCount + 1)
        for i in 0..<branchCount {
            let branch = SKNode()
            branch.position = CGPoint(x: size.width / 2, y: branchSpacing * CGFloat(i + 1))
            
            // Визуальное представление ветки – коричневая полоска
            let branchVisual = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: 10))
            branchVisual.fillColor = .brown
            branchVisual.strokeColor = .brown
            branchVisual.position = .zero
            branch.addChild(branchVisual)
            
            addChild(branch)
            branches.append(branch)
        }
        
        if difficulty == .easy {
            // На лёгком уровне используется схема:
            // Если веток N, то заполняются ровно N-1 веток, а одна остается пустой.
            // При этом для веток: если N == 3 -> 2 цвета (2 * 4 = 8 птиц),
            // если N == 4 -> 3 цвета (3 * 4 = 12 птиц).
            let branchesToFill = branchCount - 1  // заполняем ровно N-1 веток
            // birdColors.count должна равняться branchesToFill (3 ветки → 2 цвета, 4 ветки → 3 цвета)
            var birdsArray: [UIColor] = []
            for color in birdColors {
                birdsArray.append(contentsOf: Array(repeating: color, count: 4))
            }
            birdsArray.shuffle()
            
            // Случайно выбираем одну ветку, которая останется пустой
            let emptyBranchIndex = Int.random(in: 0..<branchCount)
            var birdIndex = 0
            for (index, branch) in branches.enumerated() {
                if index == emptyBranchIndex {
                    // Оставляем ветку пустой
                    continue
                } else {
                    // Заполняем ветку ровно 4 птицами
                    for slot in 0..<4 {
                        if birdIndex < birdsArray.count {
                            let color = birdsArray[birdIndex]
                            birdIndex += 1
                            let bird = SKSpriteNode(color: color, size: CGSize(width: 30, height: 30))
                            let branchWidth = size.width * 0.8
                            let birdSpacing: CGFloat = branchWidth / CGFloat(4 + 1)
                            let posX = -branchWidth / 2 + birdSpacing * CGFloat(slot + 1)
                            bird.position = CGPoint(x: posX, y: 20)
                            bird.name = "bird"
                            branch.addChild(bird)
                        }
                    }
                }
            }
        } else {
            // Для средних и сложных уровней заполняем каждую ветку 4 птицами случайным образом
            for branch in branches {
                let birdCount = 4
                let branchWidth = size.width * 0.8
                let birdSpacing: CGFloat = branchWidth / CGFloat(birdCount + 1)
                for j in 0..<birdCount {
                    let color = birdColors.randomElement() ?? .red
                    let bird = SKSpriteNode(color: color, size: CGSize(width: 30, height: 30))
                    let posX = -branchWidth / 2 + birdSpacing * CGFloat(j + 1)
                    bird.position = CGPoint(x: posX, y: 20)
                    bird.name = "bird"
                    branch.addChild(bird)
                }
            }
        }
    }
    
    // Обработка касаний: выбор и перемещение птиц
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodeAtLocation = atPoint(location)
        
        // Если нажата птица
        if let bird = nodeAtLocation as? SKSpriteNode, bird.name == "bird" {
            if let branch = branchForNode(bird) {
                if isBirdMovable(bird, in: branch) {
                    selectedBird?.run(SKAction.scale(to: 1.0, duration: 0.1))
                    selectedBird = bird
                    bird.run(SKAction.scale(to: 1.2, duration: 0.1))
                }
            }
        } else {
            // Если нажата ветка или пустое место, перемещаем выбранную птицу
            if let selected = selectedBird {
                if let targetBranch = branchForNode(nodeAtLocation) {
                    if canPlaceBird(on: targetBranch) {
                        moveBird(selected, to: targetBranch)
                        if difficulty == .hard {
                            movesMade += 1
                            if movesMade >= maxMoves {
                                gameOver(victory: false)
                                return
                            }
                        }
                        selectedBird = nil
                    }
                }
            }
        }
    }
    
    // Находим ветку, к которой относится узел (сам узел или его родитель)
    func branchForNode(_ node: SKNode) -> SKNode? {
        if branches.contains(node) {
            return node
        } else if let parent = node.parent, branches.contains(parent) {
            return parent
        }
        return nil
    }
    
    // Проверяем, можно ли переместить выбранную птицу (перемещать можно только крайнюю птицу ветки)
    func isBirdMovable(_ bird: SKSpriteNode, in branch: SKNode) -> Bool {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        if birds.isEmpty { return false }
        let sortedBirds = birds.sorted { $0.position.x < $1.position.x }
        return bird == sortedBirds.first || bird == sortedBirds.last
    }
    
    // Проверка возможности посадить птицу на ветку (если есть место)
    func canPlaceBird(on branch: SKNode) -> Bool {
        let birds = branch.children.filter { $0.name == "bird" }
        return birds.count < 4
    }
    
    // Перемещение птицы с анимацией
    func moveBird(_ bird: SKSpriteNode, to targetBranch: SKNode) {
        bird.removeFromParent()
        let birds = targetBranch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        let birdCount = birds.count
        let branchWidth = size.width * 0.8
        let birdSpacing: CGFloat = branchWidth / CGFloat(4 + 1)
        let newX = -branchWidth / 2 + birdSpacing * CGFloat(birdCount + 1)
        let newPosition = CGPoint(x: newX, y: 20)
        bird.position = newPosition
        targetBranch.addChild(bird)
        
        checkBranchForFlyAway(targetBranch)
    }
    
    // Если ветка заполнена (4 птицы) и все птицы одного цвета – они «улетают»
    func checkBranchForFlyAway(_ branch: SKNode) {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        guard birds.count == 4 else { return }
        guard let firstColor = birds.first?.color else { return }
        for bird in birds {
            if bird.color != firstColor {
                return
            }
        }
        
        let flyAway = SKAction.moveBy(x: 0, y: size.height, duration: 1.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([flyAway, remove])
        for bird in birds {
            bird.run(sequence)
        }
        
        run(SKAction.sequence([SKAction.wait(forDuration: 1.2),
                               SKAction.run { [weak self] in
            self?.checkWinCondition()
        }]))
    }
    
    // Победа, если все ветки очищены от птиц
    func checkWinCondition() {
        for branch in branches {
            let birds = branch.children.filter { $0.name == "bird" }
            if !birds.isEmpty {
                return
            }
        }
        gameOver(victory: true)
    }
    
    // Завершение игры с сообщением и перезапуском
    func gameOver(victory: Bool) {
        let message = victory ? "Победа!" : "Игра окончена!"
        let label = SKLabelNode(text: message)
        label.fontSize = 40
        label.fontColor = .black
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.restartGame()
            }
        ]))
    }
    
    // Перезапуск игры
    func restartGame() {
        removeAllChildren()
        movesMade = 0
        selectedBird = nil
        didMove(to: self.view!)
    }
}

#Preview {
    ContentView()
}
