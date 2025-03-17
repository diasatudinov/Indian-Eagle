import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var gameScene: GameScene = {
           let scene = GameScene(size: UIScreen.main.bounds.size)
           scene.scaleMode = .resizeFill
        scene.difficulty = .hard  // Можно менять сложность
           return scene
       }()
       
       var body: some View {
           ZStack {
               SpriteView(scene: gameScene)
                   .ignoresSafeArea()
               VStack {
                   HStack {
                       Spacer()
                       Button(action: {
                           // Вызываем перезапуск игры
                           gameScene.restartGame()
                       }) {
                           Text("Перезапуск")
                               .padding(10)
                               .background(Color.black.opacity(0.7))
                               .foregroundColor(.white)
                               .cornerRadius(8)
                       }
                       .padding()
                   }
                   Spacer()
               }
           }
       }
   }

// MARK: - Основная игровая сцена

class GameScene: SKScene {
    
    enum Difficulty {
        case easy, medium, hard
    }
    
    var difficulty: Difficulty = .easy
    
    // Параметры игры: число веток и набор цветов для птиц
    var branchCount: Int = 4
    var birdColors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.green]
    var maxMoves: Int = 0  // Для сложного уровня
    
    // Массив веток (каждая ветка – SKNode)
    var branches: [SKNode] = []
    
    // Выбранная группа птиц для перемещения (при групповом перемещении)
    var selectedBirdGroup: [SKSpriteNode] = []
    
    // Счётчик ходов (для сложного уровня)
    var movesMade: Int = 0
    
    // Константы для оформления
    let branchMargin: CGFloat = 10.0     // отступ от края экрана
    var branchWidth: CGFloat {
        return size.width * 0.45          // длина ветки чуть меньше половины экрана
    }
    let branchHeight: CGFloat = 10.0
    let birdSize = CGSize(width: 30, height: 25) // прямоугольные птицы
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        
        // Настройка параметров сложности и конфигурация веток/цветов по условиям:
        switch difficulty {
        case .easy:
            branchCount = Int.random(in: 4...5)
            if branchCount == 4 {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green]
            } else {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
            }
            maxMoves = 0  // без ограничения ходов
            
        case .medium:
            branchCount = Int.random(in: 5...6)
            if branchCount == 5 {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
            } else {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
            }
            maxMoves = 0
            
        case .hard:
            branchCount = Int.random(in: 6...7)
            if branchCount == 6 {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple]
            } else {
                birdColors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple, UIColor.orange]
            }
            maxMoves = 20
        }
        
        createBranches()
    }
    
    // MARK: - Создание веток и заполнение птицами
    
    func createBranches() {
        // Удаляем старые ветки
        for branch in branches {
            branch.removeFromParent()
        }
        branches.removeAll()
        
        // Располагаем ветки по вертикали равномерно
        let branchSpacingY = size.height / CGFloat(branchCount + 1)
        for i in 0..<branchCount {
            let branch = SKNode()
            let branchY = branchSpacingY * CGFloat(i + 1)
            // Чередуем расположение: четные – слева, нечетные – справа
            if i % 2 == 0 {
                branch.position = CGPoint(x: branchMargin + branchWidth / 2, y: branchY)
            } else {
                branch.position = CGPoint(x: size.width - (branchMargin + branchWidth / 2), y: branchY)
            }
            // Визуальное представление ветки – коричневая полоска
            let branchVisual = SKShapeNode(rectOf: CGSize(width: branchWidth, height: branchHeight))
            branchVisual.fillColor = .brown
            branchVisual.strokeColor = .brown
            branchVisual.position = .zero
            branch.addChild(branchVisual)
            
            addChild(branch)
            branches.append(branch)
        }
        
        if difficulty == .easy {
            // На Easy-уровне заполняются ровно (branchCount - 1) веток (одна остаётся пустой)
            // Всего птиц: (branchCount - 1) * 4, каждого цвета ровно по 4 экземпляра.
            var birdsArray: [UIColor] = []
            for color in birdColors {
                birdsArray.append(contentsOf: Array(repeating: color, count: 4))
            }
            birdsArray.shuffle()
            
            let emptyBranchIndex = Int.random(in: 0..<branchCount)
            var birdIndex = 0
            for (index, branch) in branches.enumerated() {
                if index == emptyBranchIndex {
                    continue // оставляем ветку пустой
                } else {
                    let slots = 4
                    let spacing = branchWidth / CGFloat(slots + 1)
                    for slot in 0..<slots {
                        if birdIndex < birdsArray.count {
                            let color = birdsArray[birdIndex]
                            birdIndex += 1
                            let bird = SKSpriteNode(color: color, size: birdSize)
                            let posX = -branchWidth / 2 + spacing * CGFloat(slot + 1)
                            bird.position = CGPoint(x: posX, y: branchHeight / 2 + birdSize.height / 2)
                            bird.name = "bird"
                            branch.addChild(bird)
                        }
                    }
                }
            }
        } else {
            // Для medium и hard уровней – заполняем каждую ветку 4 птицами случайным образом
            for branch in branches {
                let slots = 4
                let spacing = branchWidth / CGFloat(slots + 1)
                for j in 0..<slots {
                    let color = birdColors.randomElement() ?? .red
                    let bird = SKSpriteNode(color: color, size: birdSize)
                    let posX = -branchWidth / 2 + spacing * CGFloat(j + 1)
                    bird.position = CGPoint(x: posX, y: branchHeight / 2 + birdSize.height / 2)
                    bird.name = "bird"
                    branch.addChild(bird)
                }
            }
        }
    }
    
    // MARK: - Выбор группы птиц для перемещения
    
    /// Если нажата крайняя птица, возвращает группу подряд идущих птиц того же цвета.
    func getMovableGroup(for bird: SKSpriteNode, in branch: SKNode) -> [SKSpriteNode]? {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        let sortedBirds = birds.sorted { $0.position.x < $1.position.x }
        guard let firstBird = sortedBirds.first, let lastBird = sortedBirds.last else { return nil }
        
        if bird == firstBird {
            var group: [SKSpriteNode] = []
            for b in sortedBirds {
                if b.color == bird.color {
                    group.append(b)
                } else {
                    break
                }
            }
            return group
        } else if bird == lastBird {
            var group: [SKSpriteNode] = []
            for b in sortedBirds.reversed() {
                if b.color == bird.color {
                    group.append(b)
                } else {
                    break
                }
            }
            return group
        }
        return nil
    }
    
    // MARK: - Обработка касаний
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodeAtLocation = atPoint(location)
        
        // Если нажата птица – пытаемся выбрать группу, если птица находится на краю ветки
        if let bird = nodeAtLocation as? SKSpriteNode, bird.name == "bird" {
            if let branch = branchForNode(bird),
               let group = getMovableGroup(for: bird, in: branch) {
                // Сброс предыдущего выделения
                for b in selectedBirdGroup {
                    b.run(SKAction.scale(to: 1.0, duration: 0.1))
                }
                selectedBirdGroup = group
                for b in selectedBirdGroup {
                    b.run(SKAction.scale(to: 1.2, duration: 0.1))
                }
            }
        } else {
            // Если нажата ветка или пустое место – перемещаем выбранную группу, если на целевой ветке есть место
            if !selectedBirdGroup.isEmpty,
               let targetBranch = branchForNode(nodeAtLocation),
               canPlaceBird(on: targetBranch) {
                moveBirdGroup(selectedBirdGroup, to: targetBranch)
                if difficulty == .hard {
                    movesMade += 1
                    if movesMade >= maxMoves {
                        gameOver(victory: false)
                        return
                    }
                }
                selectedBirdGroup.removeAll()
            }
        }
    }
    
    // Возвращает ветку, к которой относится узел (либо сам узел, либо его родитель)
    func branchForNode(_ node: SKNode) -> SKNode? {
        if branches.contains(node) {
            return node
        } else if let parent = node.parent, branches.contains(parent) {
            return parent
        }
        return nil
    }
    
    // Проверяем, можно ли посадить птицу на ветку (максимум 4 птицы)
    func canPlaceBird(on branch: SKNode) -> Bool {
        let birds = branch.children.filter { $0.name == "bird" }
        return birds.count < 4
    }
    
    // MARK: - Перемещение группы птиц с учетом нового правила
    //
    // Новое правило: перемещение группы (или одной птицы) возможно, если:
    // • целевая ветка пуста (в этом случае используется правило посадки ближе к краю)
    // или
    // • выбранный свободный слот (в ветке, где уже есть птицы) имеет хотя бы одного соседа (слева или справа)
    //   с птицей того же цвета, что и перемещаемая группа.
    func moveBirdGroup(_ birds: [SKSpriteNode], to targetBranch: SKNode) {
        let slots = 4
        let spacing = branchWidth / CGFloat(slots + 1)
        
        // Вычисляем фиксированные позиции слотов (локальные координаты ветки)
        var slotPositions: [CGFloat] = []
        for i in 0..<slots {
            let posX = -branchWidth / 2 + spacing * CGFloat(i + 1)
            slotPositions.append(posX)
        }
        
        let existingBirds = targetBranch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        
        // Если целевая ветка пуста – используем правило посадки ближе к краю
        if existingBirds.isEmpty {
            let movingCount = min(birds.count, slots)
            var chosenSlots: [CGFloat] = []
            if targetBranch.position.x < size.width / 2 {
                // левая ветка – выбираем первые слоты (ближе к левому краю)
                chosenSlots = Array(slotPositions.prefix(movingCount))
            } else {
                // правая ветка – выбираем последние слоты (ближе к правому краю)
                chosenSlots = Array(slotPositions.suffix(movingCount))
            }
            for (i, bird) in birds.prefix(movingCount).enumerated() {
                bird.removeFromParent()
                let newPosition = CGPoint(x: chosenSlots[i], y: branchHeight / 2 + birdSize.height / 2)
                bird.position = newPosition
                targetBranch.addChild(bird)
            }
            checkBranchForFlyAway(targetBranch)
            return
        }
        
        // Если ветка не пуста – составляем маппинг занятых слотов
        let tolerance: CGFloat = 5.0
        var occupiedMapping: [Int: SKSpriteNode] = [:]
        for bird in existingBirds {
            for (index, posX) in slotPositions.enumerated() {
                if abs(bird.position.x - posX) < tolerance {
                    occupiedMapping[index] = bird
                    break
                }
            }
        }
        
        // Определяем свободные слоты
        var freeSlots: [(index: Int, pos: CGFloat)] = []
        for (index, pos) in slotPositions.enumerated() {
            if occupiedMapping[index] == nil {
                freeSlots.append((index, pos))
            }
        }
        
        // Фильтруем свободные слоты по новому правилу:
        // Слот считается допустимым, если хотя бы один его сосед (индекс-1 или индекс+1)
        // занят птицей того же окраски, что и перемещаемая группа.
        guard let movingColor = birds.first?.color else { return }
        freeSlots = freeSlots.filter { candidate in
            let index = candidate.index
            var valid = false
            if index - 1 >= 0, let neighbor = occupiedMapping[index - 1] {
                if neighbor.color == movingColor { valid = true }
            }
            if index + 1 < slots, let neighbor = occupiedMapping[index + 1] {
                if neighbor.color == movingColor { valid = true }
            }
            return valid
        }
        
        // Если нет допустимых свободных слотов – перемещение не производится.
        if freeSlots.isEmpty { return }
        
        freeSlots.sort { abs($0.pos) < abs($1.pos) }
        let freeCount = freeSlots.count
        let movingCount = min(birds.count, freeCount)
        for i in 0..<movingCount {
            let newX = freeSlots[i].pos
            let newPosition = CGPoint(x: newX, y: branchHeight / 2 + birdSize.height / 2)
            let bird = birds[i]
            bird.removeFromParent()
            bird.position = newPosition
            targetBranch.addChild(bird)
        }
        
        checkBranchForFlyAway(targetBranch)
    }
    
    // MARK: - Проверка ветки: если заполнена 4 птицами одного цвета – птицы улетают, а ветка исчезает
    
    func checkBranchForFlyAway(_ branch: SKNode) {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        guard birds.count == 4, let firstColor = birds.first?.color else { return }
        for bird in birds {
            if bird.color != firstColor {
                return
            }
        }
        
        let flyAway = SKAction.moveBy(x: 0, y: size.height, duration: 1.0)
        let removeBirdAction = SKAction.removeFromParent()
        let birdSequence = SKAction.sequence([flyAway, removeBirdAction])
        for bird in birds {
            bird.run(birdSequence)
        }
        
        branch.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent(),
            SKAction.run { [weak self] in
                if let index = self?.branches.firstIndex(of: branch) {
                    self?.branches.remove(at: index)
                }
                self?.checkWinCondition()
            }
        ]))
    }
    
    // MARK: - Проверка условия победы
    
    func checkWinCondition() {
        for branch in branches {
            let birds = branch.children.filter { $0.name == "bird" }
            if !birds.isEmpty { return }
        }
        gameOver(victory: true)
    }
    
    // MARK: - Завершение игры и перезапуск
    
    func gameOver(victory: Bool) {
        let message = victory ? "Победа!" : "Игра окончена!"
        let label = SKLabelNode(text: message)
        label.fontSize = 40
        label.fontColor = .black
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in self?.restartGame() }
        ]))
    }
    
    func restartGame() {
        removeAllChildren()
        movesMade = 0
        selectedBirdGroup.removeAll()
        didMove(to: self.view!)
    }
    
    // MARK: - Перемещение одиночной птицы (обёртка)
    
    func moveBird(_ bird: SKSpriteNode, to targetBranch: SKNode) {
        moveBirdGroup([bird], to: targetBranch)
    }
}
#Preview {
    ContentView()
}
