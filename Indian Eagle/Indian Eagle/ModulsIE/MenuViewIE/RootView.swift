//
//  RootView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 20.03.2025.
//


import SwiftUI

struct RootView: View {
    
    @State private var isLoading = true
    @State var toUp: Bool = true
    @AppStorage("vers") var verse: Int = 0
    
    var body: some View {
        ZStack {
            if verse == 1 {
                WVWrap(urlString: Links.winStarData)
            } else {
                VStack {
                    if isLoading {
                       // SplashScreen()
                    } else {
                        MenuViewIE()
                            .onAppear {
                                AppDelegate.orientationLock = .landscape
                                setOrientation(.landscapeRight)
                            }
                            .onDisappear {
                                AppDelegate.orientationLock = .all
                            }
                            
                    }
                }
            }
        }
        .onAppear {
            updateIfNeeded()
            print("\(Links.shared.finalURL)")
           
        }
    }
    
    func updateIfNeeded() {
        if Links.shared.finalURL == nil {
            Task {
                if await !Resolver.checking() {
                    verse = 1
                    toUp = false
                    isLoading = false
                    
                } else {
                    verse = 0
                    toUp = true
                    isLoading = false
                }
            }
        } else {
            isLoading = false
        }
        
        
    }
    
    func setOrientation(_ orientation: UIInterfaceOrientation) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let selector = NSSelectorFromString("setInterfaceOrientation:")
            if let responder = windowScene.value(forKey: "keyWindow") as? UIResponder, responder.responds(to: selector) {
                responder.perform(selector, with: orientation.rawValue)
            }
        }
    }
}

#Preview {
    RootView()
}
