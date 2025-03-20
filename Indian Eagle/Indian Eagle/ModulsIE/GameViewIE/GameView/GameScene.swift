import SpriteKit

enum Difficulty {
    case easy, medium, hard
}

// MARK: - Основная игровая сцена
class GameScene: SKScene {
    
    let settingsVM = SettingsViewModelIE()
    var difficulty: Difficulty = .easy
    var allBirdNames = ["birdYellow", "birdRed1", "birdRed", "birdPink", "birdOrange", "birdGreen"]
    
    var winHandler: (() -> Void)?
    var movesHandler: (() -> Void)?
    
    // Параметры игры: число веток и набор имен для птиц (используем имена изображений)
    var branchCount: Int = 4
    var birdNames: [String] = [] // вместо birdColors
    var maxMoves: Int = 0  // Для сложного уровня
    
    // Массив веток (каждая ветка – SKNode)
    var branches: [SKNode] = []
    
    // Выбранная группа птиц для перемещения
    var selectedBirdGroup: [SKSpriteNode] = []
    
    // Счётчик ходов (для сложного уровня)
    var movesMade: Int = 0
    
    // Константы для оформления
    let branchMargin: CGFloat = 0.0
    var branchWidth: CGFloat {
        return size.width * 0.45
    }
    let branchHeight: CGFloat = 10.0
    let birdSize = CGSize(width: DeviceInfoIE.shared.deviceType == .pad ? 60:30, height: DeviceInfoIE.shared.deviceType == .pad ? 110:55) // размер картинки птицы
    
    let birdFlapSound = SKAction.playSoundFileNamed("birdWingsIE.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        backgroundColor = .clear
        
        // Настройка параметров сложности и конфигурация веток/птичек по условиям:
        switch difficulty {
            case .easy:
                branchCount = Int.random(in: 4...5)
                maxMoves = 0  // без ограничения ходов
            case .medium:
                branchCount = Int.random(in: 5...6)
                maxMoves = 0
            case .hard:
                branchCount = Int.random(in: 6...7)
                maxMoves = 0
            }
            
            // Выбираем количество видов птиц в зависимости от числа веток:
            // если branchCount == 4 → 3 типа, 5 → 4 типа, 6 → 5 типа, 7 → 6 типа (то есть весь массив)
            var typesCount = branchCount - 1
            typesCount = min(typesCount, allBirdNames.count)
            
            // Перемешиваем массив и выбираем первые typesCount элементов
            birdNames = Array(allBirdNames.shuffled().prefix(typesCount))
        
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
            
            // Чередуем расположение веток: четные – слева, нечетные – справа
            if i % 2 == 0 {
                branch.position = CGPoint(x: branchMargin + branchWidth / 2, y: branchY)
            } else {
                branch.position = CGPoint(x: size.width - (branchMargin + branchWidth / 2), y: branchY)
            }
            
            // Создаем ветку как изображение
            let branchSprite = SKSpriteNode(imageNamed: "branchImage")
            // Масштабируем изображение так, чтобы его ширина равнялась branchWidth
            let scaleFactor = branchWidth / branchSprite.size.width
            branchSprite.setScale(scaleFactor)
            branchSprite.position = CGPoint(x: 0, y: 0)
            // Устанавливаем zPosition так, чтобы ветка была поверх птиц
            branchSprite.zPosition = 0
            
            // Если ветка находится слева от центра, переворачиваем изображение (т.к. картинка ориентирована налево)
            if branch.position.x < size.width / 2 {
                branchSprite.xScale = -abs(branchSprite.xScale)
            }
            
            // Добавляем изображение ветки в узел ветки
            branch.addChild(branchSprite)
            addChild(branch)
            branches.append(branch)
        }
        
        // Создаем массив птиц: каждая птица встречается 4 раза
        var birdsArray: [String] = []
        for name in birdNames {
            birdsArray.append(contentsOf: Array(repeating: name, count: 4))
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
        
        // Определяем 4 фиксированные позиции по оси X в пределах ветки (локальные координаты)
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
            // Определяем, с какой стороны находится ветка:
            // для левой ветки – слоты сортируются по возрастанию (от края к центру),
            // для правой – по убыванию (так, чтобы птицы смотрели в центр)
            let isLeftBranch = branch.position.x < size.width / 2
            let orderedSlots = isLeftBranch ? fixedSlotPositions.sorted(by: { $0 < $1 })
                                            : fixedSlotPositions.sorted(by: { $0 > $1 })
            
            // Получаем branchSprite для расчёта вертикального смещения птиц
            guard let branchSprite = branch.children.first as? SKSpriteNode else { continue }
            // Коэффициент перекрытия: доля высоты птицы, которая будет скрыта за веткой
            let birdOverlapFactor: CGFloat = 0.4
            // Вычисляем y-позицию для птиц так, чтобы их нижняя часть была за веткой.
            // branchSprite имеет якорь (0.5, 0.5), значит его нижняя граница = -branchSprite.size.height/2.
            // Добавляем смещение: часть высоты птицы (например, 40%) будет скрыта.
            let birdSeatY = -branchSprite.size.height/2 + (birdSize.height * (1 - birdOverlapFactor)) + birdSize.height/2
            
            for slot in 0..<birdsToPlace {
                if birdIndex < birdsArray.count {
                    let imageName = birdsArray[birdIndex]
                    birdIndex += 1
                    // Создаем птицу с изображением
                    let bird = SKSpriteNode(imageNamed: imageName)
                    bird.size = birdSize
                    let posX = orderedSlots[slot]
                    bird.position = CGPoint(x: posX, y: birdSeatY)
                    bird.name = "bird"
                    // Сохраняем тип птицы для логики (например, сравнения при перемещении)
                    bird.userData = NSMutableDictionary()
                    bird.userData?["birdType"] = imageName
                    // Если ветка находится справа, переворачиваем птицу по горизонтали, чтобы смотреть в центр
                    if !isLeftBranch {
                        bird.xScale = -abs(bird.xScale)
                    } else {
                        bird.xScale = abs(bird.xScale)
                    }
                    // Размещаем птицу позади ветки (zPosition ниже ветки)
                    bird.zPosition = 1
                    branch.addChild(bird)
                }
            }
        }
    }
    
    // MARK: - Выбор группы птиц для перемещения
    /// Если нажата крайняя птичка, возвращает группу подряд идущих птиц того же типа.
    func getMovableGroup(for bird: SKSpriteNode, in branch: SKNode) -> [SKSpriteNode]? {
        // Получаем всех птиц на ветке и сортируем по локальной x (от меньшего к большему)
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        let sortedBirds = birds.sorted { $0.position.x < $1.position.x }
        
        // Определяем сторону ветки: если branch.position.x меньше центра, то ветка слева
        let isLeftBranch = branch.position.x < size.width / 2
        
        // Для ветки слева, внутренняя (центрированная) птица – последняя (с максимальным x).
        // Для ветки справа – первая (с минимальным x).
        if isLeftBranch {
            guard let innerBird = sortedBirds.last, innerBird == bird else {
                return nil
            }
        } else {
            guard let innerBird = sortedBirds.first, innerBird == bird else {
                return nil
            }
        }
        
        // Если условие выполнено, собираем группу подряд идущих птиц того же типа,
        // начиная с выбранной (которая находится на внутреннем краю) и расширяясь в сторону края ветки.
        guard let tappedType = bird.userData?["birdType"] as? String,
              let index = sortedBirds.firstIndex(of: bird) else {
            return nil
        }
        
        var group: [SKSpriteNode] = [bird]
        
        if isLeftBranch {
            // Для ветки слева, двигаемся влево (к краю ветки)
            var i = index - 1
            while i >= 0 {
                let otherBird = sortedBirds[i]
                if let type = otherBird.userData?["birdType"] as? String, type == tappedType {
                    group.insert(otherBird, at: 0)
                } else {
                    break
                }
                i -= 1
            }
        } else {
            // Для ветки справа, двигаемся вправо (к краю ветки)
            var i = index + 1
            while i < sortedBirds.count {
                let otherBird = sortedBirds[i]
                if let type = otherBird.userData?["birdType"] as? String, type == tappedType {
                    group.append(otherBird)
                } else {
                    break
                }
                i += 1
            }
        }
        
        return group
    }
    
    // MARK: - Обработка касаний
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        var touchedBird: SKSpriteNode? = nil
        // Ищем первый узел с name "bird"
        for node in touchedNodes {
            if let sprite = node as? SKSpriteNode, sprite.name == "bird" {
                touchedBird = sprite
                break
            }
        }
        
        if let bird = touchedBird {
            if let branch = branchForNode(bird),
               let group = getMovableGroup(for: bird, in: branch) {
                // Сброс предыдущего выделения – восстанавливаем масштаб с сохранением направления:
                for b in selectedBirdGroup {
                    let parentX = b.parent?.position.x ?? 0
                    let desiredXScale: CGFloat = parentX < size.width/2 ? 1.0 : -1.0
                    let resetX = SKAction.scaleX(to: desiredXScale, duration: 0.1)
                    let resetY = SKAction.scaleY(to: 1.0, duration: 0.1)
                    b.run(SKAction.group([resetX, resetY]))
                }
                selectedBirdGroup = group
                // Визуальное выделение выбранной группы – масштабирование без смены знака:
                for b in selectedBirdGroup {
                    let parentX = b.parent?.position.x ?? 0
                    let desiredXScale: CGFloat = parentX < size.width/2 ? 1.2 : -1.2
                    let scaleX = SKAction.scaleX(to: desiredXScale, duration: 0.1)
                    let scaleY = SKAction.scaleY(to: 1.2, duration: 0.1)
                    b.run(SKAction.group([scaleX, scaleY]))
                }
            }
            return
        } else {
            // Если не нажата птица – перемещаем выбранную группу, если возможно
            if !selectedBirdGroup.isEmpty,
               let targetBranch = branchForNode(touchedNodes.first ?? self),
               canPlaceBird(on: targetBranch) {
                moveBirdGroup(selectedBirdGroup, to: targetBranch)
                if difficulty == .hard {
                    movesMade += 1
                    movesHandler?()
//                    if movesMade >= maxMoves {
//                        gameOver(victory: false)
//                        return
//                    }
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
        
        // 2. Определяем, с какой стороны расположена целевая ветка
        let targetIsLeft = targetBranch.position.x < size.width / 2
        
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
        
        // 4. Выбираем свободные позиции для посадки
        var chosenSlots: [CGFloat] = []
        if existingBirds.isEmpty {
            let orderedSlots: [CGFloat] = targetIsLeft ? slotPositions.sorted(by: { $0 < $1 })
                                                       : slotPositions.sorted(by: { $0 > $1 })
            let movingCount = min(birds.count, slots)
            chosenSlots = Array(orderedSlots.prefix(movingCount))
        } else {
            var freeSlots: [(index: Int, pos: CGFloat)] = []
            for (index, pos) in slotPositions.enumerated() {
                if !occupiedIndices.contains(index) {
                    freeSlots.append((index, pos))
                }
            }
            freeSlots.sort { abs($0.pos) < abs($1.pos) }
            let movingCount = min(birds.count, freeSlots.count)
            chosenSlots = freeSlots.prefix(movingCount).map { $0.pos }
        }
        
        // 5. Определяем сторону исходной ветки
        guard let sourceBranch = birds.first?.parent else { return }
        let sourceIsLeft = sourceBranch.position.x < size.width / 2
        
        // 6. Анимация перелёта
        let animationDuration = 1.0
        let movingCount = min(birds.count, chosenSlots.count)
        var completedMoves = 0
        
        
        for i in 0..<movingCount {
            let bird = birds[i]
            // Целевая позиция в локальной системе координат ветки
            let newLocalPosition = CGPoint(x: chosenSlots[i], y: branchHeight / 2 + birdSize.height / 2)
            // Переводим в координаты сцены
            let finalScenePosition = targetBranch.convert(newLocalPosition, to: self)
            let startScenePosition = bird.parent?.convert(bird.position, to: self) ?? bird.position
            
            // Перед анимацией меняем текстуру на версию для полёта
            if let birdType = bird.userData?["birdType"] as? String {
                bird.texture = SKTexture(imageNamed: "\(birdType)_fly")
            }
            
            // Перемещаем птицу в корень сцены для анимации
            bird.removeFromParent()
            bird.position = startScenePosition
            addChild(bird)
            
            let moveAction = SKAction.move(to: finalScenePosition, duration: animationDuration)
            if settingsVM.soundEnabled {
                bird.run(birdFlapSound)
            }
            bird.run(moveAction) {
                // После анимации возвращаем птицу на целевую ветку
                bird.removeFromParent()
                bird.position = newLocalPosition
                // Если перелёт происходил между сторонами, корректируем ориентацию
                if sourceIsLeft != targetIsLeft {
                    if targetIsLeft {
                        bird.xScale = abs(bird.xScale)
                    } else {
                        bird.xScale = -abs(bird.xScale)
                    }
                }
                // После посадки возвращаем обычную текстуру (сидящую)
                if let birdType = bird.userData?["birdType"] as? String {
                    bird.texture = SKTexture(imageNamed: birdType)
                }
                targetBranch.addChild(bird)
                
                completedMoves += 1
                if completedMoves == movingCount {
                    self.checkBranchForFlyAway(targetBranch)
                }
            }
        }
    }
    
    // MARK: - Проверка ветки: если заполнена 4 птицами одного типа – птицы улетают, а ветка исчезает
    func checkBranchForFlyAway(_ branch: SKNode) {
        let birds = branch.children.filter { $0.name == "bird" } as! [SKSpriteNode]
        guard birds.count == 4, let firstType = birds.first?.userData?["birdType"] as? String else { return }
        for bird in birds {
            if let type = bird.userData?["birdType"] as? String, type != firstType {
                return
            }
        }
        
        // Перед анимацией вылёта обновляем текстуру на летящую версию
        for bird in birds {
            if let birdType = bird.userData?["birdType"] as? String {
                bird.texture = SKTexture(imageNamed: "\(birdType)_fly")
            }
        }
        
        // Анимация вылёта птиц
        let flyAway = SKAction.moveBy(x: 0, y: size.height, duration: 2.0)
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
        if victory {
            winHandler?()
        }
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
