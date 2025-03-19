import SwiftUI

class Links {
    
    static let shared = Links()
    
    static let winStarData = "https://isletaonline.xyz/info"
    //"?page=test"
   // static let privacyData = "https://isletaonline.xyz/"
    
    @AppStorage("finalUrl") var finalURL: URL?
    
    
}