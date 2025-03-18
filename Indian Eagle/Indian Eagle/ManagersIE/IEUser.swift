//
//  IEUser.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 18.03.2025.
//


import SwiftUI

class IEUser: ObservableObject {
    static let shared = IEUser()
    @Published var openTournament = false
    @AppStorage("coins") var storedCoins: Int = 10
    @Published var coins: Int = 10
    
    init() {
        coins = storedCoins

    }
    
    
    func updateUserCoins(for coins: Int) {
        self.coins += coins
        storedCoins = self.coins
    }
    
    func minusUserCoins(for coins: Int) {
        self.coins -= coins
        if self.coins < 0 {
            self.coins = 0
        }
        storedCoins = self.coins
        
    }
    
}
