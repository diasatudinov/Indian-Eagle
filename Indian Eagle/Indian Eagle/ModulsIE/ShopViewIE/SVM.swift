//
//  SVM.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//


import SwiftUI

class SVM: ObservableObject {
    @Published var shopTeamItems: [Item] = [
        Item(type: .team, name: "Team Ordinary", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"])

    ]
    
    @Published var shopSetItems: [Item] = [
        Item(type: .set, name: "Ordinary Set", images: [])

    ]
    
    @Published var currentTeamItem: Item? {
        didSet {
            saveTeam()
        }
    }
    
    init() {
        loadTeam()
    }
    
    private let userDefaultsTeamKey = "boughtItem"
    
//    func getRandomItem() -> [String] {
//        if let currentItem = currentItem {
//            let availableItems = shopTeamItems.filter { $0.name != currentItem.name }
//            return availableItems.randomElement()?.images ?? []
//        }
//        return []
//    }
    
    func saveTeam() {
        if let currentItem = currentTeamItem {
            if let encodedData = try? JSONEncoder().encode(currentItem) {
                UserDefaults.standard.set(encodedData, forKey: userDefaultsTeamKey)
            }
        }
    }
    
    func loadTeam() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsTeamKey),
           let loadedItem = try? JSONDecoder().decode(Item.self, from: savedData) {
            currentTeamItem = loadedItem
        } else {
            currentTeamItem = shopTeamItems[0]
            print("No saved data found")
        }
    }
    
}

enum ItemType: Codable, Hashable {
    case set, team
}
struct Item: Codable, Hashable {
    var id = UUID()
    var type: ItemType
    var name: String
    var images: [String]
}
