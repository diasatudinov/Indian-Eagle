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
    let branchMargin: CGFloat = 10.0
    var branchWidth: CGFloat {
        return size.width * 0.45
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
        
        // Располагаем ветки по вертикали
        let branchSpacingY = size.height / CGFloat(branchCount + 1)
        for i in 0..<branchCount {
            let branch = SKNode()
            let branchY = branchSpacingY * CGFloat(i + 1)
            
            // Чередуем расположение веток: чётные – слева, нечётные – справа
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
        
        // Создаем массив птиц: каждая птица встречается 4 раза
        var birdsArray: [UIColor] = []
        for color in birdColors {
            birdsArray.append(contentsOf: Array(repeating: color, count: 4))
        }
        birdsArray.shuffle()
        
        // Определяем, сколько птиц будет на каждой ветке (от 2 до 4)
        var slotsPerBranch: [Int] = []
        var totalSlots = 0
        for _ in branches {
            let slots = Int.random(in: 2...4)
            slotsPerBranch.append(slots)
            totalSlots += slots
        }
        
        // Корректируем общее число слотов, чтобы их сумма совпадала с числом птиц
        let birdCount = birdsArray.count
        while totalSlots > birdCount {
            if let index = slotsPerBranch.firstIndex(where: { $0 > 2 }) {
                slotsPerBranch[index] -= 1
                totalSlots -= 1
            }
        }
        while totalSlots < birdCount {
            if let index = slotsPerBranch.firstIndex(where: { $0 < 4 }) {
                slotsPerBranch[index] += 1
                totalSlots += 1
            }
        }
        
        // Определяем 4 фиксированные позиции на ветке (локальные координаты)
        let fixedSlots = 4
        let spacing = branchWidth / CGFloat(fixedSlots + 1)
        var fixedSlotPositions: [CGFloat] = []
        for i in 0..<fixedSlots {
            let posX = -branchWidth / 2 + spacing * CGFloat(i + 1)
            fixedSlotPositions.append(posX)
        }
        
        // Распределяем птиц по веткам согласно выбранному количеству слотов
        var birdIndex = 0
        for (i, branch) in branches.enumerated() {
            let birdsToPlace = slotsPerBranch[i]
            // Определяем, с какой стороны находится ветка: для левой – сортируем по возрастанию, для правой – по убыванию
            let isLeftBranch = branch.position.x < size.width / 2
            let orderedSlots = isLeftBranch ? fixedSlotPositions.sorted(by: { $0 < $1 })
                                            : fixedSlotPositions.sorted(by: { $0 > $1 })
            
            // Заполняем выбранное число слотов (от внешнего края к центру)
            for slot in 0..<birdsToPlace {
                if birdIndex < birdsArray.count {
                    let color = birdsArray[birdIndex]
                    birdIndex += 1
                    let bird = SKSpriteNode(color: color, size: birdSize)
                    let posX = orderedSlots[slot]
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
        // 1. Определяем 4 фиксированные позиции на ветке (локальная система координат ветки)
        let slots = 4
        let spacing = branchWidth / CGFloat(slots + 1)
        var slotPositions: [CGFloat] = []
        for i in 0..<slots {
            let posX = -branchWidth / 2 + spacing * CGFloat(i + 1)
            slotPositions.append(posX)
        }
        
        // 2. Определяем, с какой стороны расположена ветка относительно центра экрана
        // Если ветка слева, outer = наименьшее значение, если справа – наибольшее.
        let isLeftBranch = targetBranch.position.x < size.width / 2
        
        // 3. Определяем, какие позиции уже заняты
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
        
        // 4. Выбор позиций для посадки
        var chosenSlots: [CGFloat] = []
        if existingBirds.isEmpty {
            // Если ветка пуста, задаём фиксированный порядок заполнения:
            // для левой ветки – от наименьшего к наибольшему (от края к центру),
            // для правой – от наибольшего к наименьшему.
            let orderedSlots: [CGFloat] = isLeftBranch ? slotPositions.sorted(by: { $0 < $1 }) : slotPositions.sorted(by: { $0 > $1 })
            let movingCount = min(birds.count, slots)
            chosenSlots = Array(orderedSlots.prefix(movingCount))
        } else {
            // Если на ветке уже есть птицы, находим свободные позиции
            var freeSlots: [(index: Int, pos: CGFloat)] = []
            for (index, pos) in slotPositions.enumerated() {
                if !occupiedIndices.contains(index) {
                    freeSlots.append((index, pos))
                }
            }
            // Сортируем свободные слоты в том же порядке, что и для полной ветки
            let orderedFreeSlots: [CGFloat] = isLeftBranch ? freeSlots.sorted(by: { $0.pos < $1.pos }).map { $0.pos } : freeSlots.sorted(by: { $0.pos > $1.pos }).map { $0.pos }
            let movingCount = min(birds.count, orderedFreeSlots.count)
            chosenSlots = Array(orderedFreeSlots.prefix(movingCount))
        }
        
        // 5. Анимация перелёта
        let animationDuration = 0.5
        let movingCount = min(birds.count, chosenSlots.count)
        var completedMoves = 0
        
        for i in 0..<movingCount {
            let bird = birds[i]
            // Целевая позиция птицы в локальной системе координат ветки
            let newLocalPosition = CGPoint(x: chosenSlots[i], y: branchHeight / 2 + birdSize.height / 2)
            // Переводим её в координаты сцены
            let finalScenePosition = targetBranch.convert(newLocalPosition, to: self)
            // Получаем стартовую позицию птицы (в координатах сцены)
            let startScenePosition = bird.parent?.convert(bird.position, to: self) ?? bird.position
            
            // Убираем птицу из исходного родителя и добавляем в сцену для анимации
            bird.removeFromParent()
            bird.position = startScenePosition
            addChild(bird)
            
            // Запускаем анимацию перелёта к целевой позиции
            let moveAction = SKAction.move(to: finalScenePosition, duration: animationDuration)
            bird.run(moveAction) {
                // После завершения анимации возвращаем птицу на целевую ветку с нужной локальной позицией
                bird.removeFromParent()
                bird.position = newLocalPosition
                targetBranch.addChild(bird)
                
                completedMoves += 1
                if completedMoves == movingCount {
                    self.checkBranchForFlyAway(targetBranch)
                }
            }
        }
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
