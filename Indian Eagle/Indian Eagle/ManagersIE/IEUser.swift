import SwiftUI

class IEUser: ObservableObject {
    
    static let shared = IEUser()
    
    @AppStorage("birds") var storedBirds: Int = 100
    @Published var birds: Int = 100
    
    @AppStorage("stars") var storedStars: Int = 5
    @Published var stars: Int = 5
    init() {
        birds = storedBirds
        stars = storedStars
    }
    
    
    func updateUserBirds(for coins: Int) {
        self.birds += coins
        storedBirds = self.birds
    }
    
    func minusUserBirds(for birds: Int) {
        self.birds -= birds
        if self.birds < 0 {
            self.birds = 0
        }
        storedBirds = self.birds
        
    }
    
    func updateUserStars(for stars: Int) {
        self.stars += stars
        storedStars = self.stars
    }
    
    func minusUserStars(for stars: Int) {
        self.stars -= stars
        if self.stars < 0 {
            self.stars = 0
        }
        storedStars = self.stars
        
    }
    
}
