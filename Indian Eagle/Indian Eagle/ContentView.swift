import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        // Создаём сцену, можно менять размер, масштаб и уровень сложности
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        // Установите уровень сложности: .easy, .medium или .hard
        scene.difficulty = .medium
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
    
    // Параметры игры: число веток и набор цветов для птиц
    var branchCount: Int = 4
    var birdColors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.green]
    var maxMoves: Int = 0  // Для сложного уровня
    
    // Массив веток (каждая ветка – SKNode)
    var branches: [SKNode] = []
    
    // Выбранная группа птиц для перемещения
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
        // Удаляем старые ветки, если они существуют
        for branch in branches {
            branch.removeFromParent()
        }
        branches.removeAll()
        
        // Создаём ветки и располагаем их по вертикали
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
        
        // Формируем массив птиц: для каждого цвета из birdColors добавляем ровно 4 экземпляра.
        var birdsArray: [UIColor] = []
        for color in birdColors {
            birdsArray.append(contentsOf: Array(repeating: color, count: 4))
        }
        birdsArray.shuffle()
        
        // Случайно выбираем одну ветку, которая останется пустой (для возможности манёвра).
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
    }
    
    // MARK: - Выбор группы птиц для перемещения
    
    /// Если нажата крайняя птица, возвращает группу подряд идущих птиц того же цвета.
    func getMovableGroup(for bird: SKSpriteNode, in branch: SKNode) -> [SKSpriteNode]? {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        let sortedBirds = birds.sorted { $0.position.x < $1.position.x }
        guard let firstBird = sortedBirds.first, let lastBird = sortedBirds.last else { return nil }
        
        if bird == firstBird {
            // Если нажата самая левая, выбираем подряд идущие птицы от начала
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
            // Если нажата самая правая, выбираем подряд идущие птицы с конца
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
                // Визуальное выделение выбранной группы
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
    
    // Разрешается перемещение (группа может перемещаться, если начинается с крайней птицы)
    func isBirdMovable(_ bird: SKSpriteNode, in branch: SKNode) -> Bool {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        guard !birds.isEmpty else { return false }
        let sortedBirds = birds.sorted { $0.position.x < $1.position.x }
        return (bird == sortedBirds.first || bird == sortedBirds.last)
    }
    
    // Проверяем, можно ли посадить птицу на ветку (максимум 4 птицы)
    func canPlaceBird(on branch: SKNode) -> Bool {
        let birds = branch.children.filter { $0.name == "bird" }
        return birds.count < 4
    }
    
    // MARK: - Перемещение группы птиц на целевую ветку
    
    func moveBirdGroup(_ birds: [SKSpriteNode], to targetBranch: SKNode) {
        // Определяем количество свободных слотов в целевой ветке
        let slots = 4
        let spacing = branchWidth / CGFloat(slots + 1)
        
        // Вычисляем позиции слотов (локальные координаты ветки)
        var slotPositions: [CGFloat] = []
        for i in 0..<slots {
            let posX = -branchWidth / 2 + spacing * CGFloat(i + 1)
            slotPositions.append(posX)
        }
        
        // Определяем число уже занятых слотов
        let existingBirds = targetBranch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        let tolerance: CGFloat = 5.0
        var occupiedIndices = Set<Int>()
        for existingBird in existingBirds {
            let birdX = existingBird.position.x
            for (index, posX) in slotPositions.enumerated() {
                if abs(birdX - posX) < tolerance {
                    occupiedIndices.insert(index)
                    break
                }
            }
        }
        
        // Если целевая ветка пуста – используем правило: птицы садятся ближе к краю,
        // в зависимости от того, находится ветка слева или справа.
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
            // Перемещаем столько птиц, сколько свободно слотов
            for (i, bird) in birds.prefix(movingCount).enumerated() {
                // Удаляем птицу из исходной ветки (если ещё не удалена)
                bird.removeFromParent()
                let newPosition = CGPoint(x: chosenSlots[i], y: branchHeight / 2 + birdSize.height / 2)
                bird.position = newPosition
                targetBranch.addChild(bird)
            }
            // Если свободен только один слот, то переместится только одна птица из группы
            checkBranchForFlyAway(targetBranch)
            return
        }
        
        // Если ветка не пуста – ищем свободные слоты и сортируем их по близости к центру (x = 0)
        var freeSlots: [(index: Int, pos: CGFloat)] = []
        for (index, pos) in slotPositions.enumerated() {
            if !occupiedIndices.contains(index) {
                freeSlots.append((index, pos))
            }
        }
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
        
        // Анимация вылета птиц
        let flyAway = SKAction.moveBy(x: 0, y: size.height, duration: 1.0)
        let removeBirdAction = SKAction.removeFromParent()
        let birdSequence = SKAction.sequence([flyAway, removeBirdAction])
        for bird in birds {
            bird.run(birdSequence)
        }
        
        // Анимация исчезновения ветки
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
}

#Preview {
    ContentView()
}
