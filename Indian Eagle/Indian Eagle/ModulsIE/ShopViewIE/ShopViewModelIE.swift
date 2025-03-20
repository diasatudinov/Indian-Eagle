//
//  SVM.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//


import SwiftUI

class ShopViewModelIE: ObservableObject {
    @Published var shopTeamItems: [Item] = [
        
        Item(type: .team, name: "Team Ordinary", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team1Icon"),
        
        Item(type: .team, name: "Team Blue", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team2Icon"),
        
        Item(type: .team, name: "Team Red", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team3Icon"),
        
        Item(type: .team, name: "Team Pink", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team4Icon"),
        
        Item(type: .team, name: "Team Yellow", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team5Icon"),
        
        Item(type: .team, name: "Team Green", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team6Icon")
    ]
    
    @Published var shopSetItems: [Item] = [
        Item(type: .set, name: "Ordinary Set", images: [], icon: "setIcon1"),
        Item(type: .set, name: "Evening Jungle", images: [], icon: "setIcon2"),
        Item(type: .set, name: "Emerald Waterfall", images: [], icon: "setIcon3"),
        Item(type: .set, name: "Blue Lagoon", images: [], icon: "setIcon4"),
        Item(type: .set, name: "Sunset Coast", images: [], icon: "setIcon5"),
        Item(type: .set, name: "Piece of Paradise", images: [], icon: "setIcon6"),

    ]
    
    @Published var boughtItems: [Item] = [
        Item(type: .team, name: "Team Ordinary", images: ["birdYellow", "birdRed1","birdRed","birdPink","birdOrange","birdGreen"], icon: "team1Icon"),
        Item(type: .set, name: "Ordinary Set", images: [], icon: "setIcon1")
    ] {
        didSet {
            saveBoughtItem()
        }
    }
    
    @Published var currentTeamItem: Item? {
        didSet {
            saveTeam()
        }
    }
    
    @Published var currentSetItem: Item? {
        didSet {
            saveSet()
        }
    }
    
    init() {
        loadTeam()
        loadBoughtItem()
        loadBoughtSet()
    }
    
    private let userDefaultsTeamKey = "saveCurrent"
    private let userDefaultsSetKey = "saveCurrentSet"
    private let userDefaultsBoughtKey = "boughtItem"
    
    func saveSet() {
        if let currentItem = currentSetItem {
            if let encodedData = try? JSONEncoder().encode(currentItem) {
                UserDefaults.standard.set(encodedData, forKey: userDefaultsSetKey)
            }
        }
    }
    
    func loadBoughtSet() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsSetKey),
           let loadedItem = try? JSONDecoder().decode(Item.self, from: savedData) {
            currentSetItem = loadedItem
        } else {
            currentSetItem = shopSetItems[0]
            print("No saved data found")
        }
    }

    
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
    
    func saveBoughtItem() {
        if let encodedData = try? JSONEncoder().encode(boughtItems) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsBoughtKey)
        }
        
    }
    
    func loadBoughtItem() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsBoughtKey),
           let loadedItem = try? JSONDecoder().decode([Item].self, from: savedData) {
            boughtItems = loadedItem
        } else {
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
    var icon: String
}
