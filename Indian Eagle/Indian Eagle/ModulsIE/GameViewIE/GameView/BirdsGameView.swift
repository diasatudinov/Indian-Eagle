//
//  BirdsGameView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI
import SpriteKit

struct BirdsGameView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var difficulty: Difficulty
    @State private var isPause = false

    var scene: SKScene {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.difficulty = difficulty
        return scene
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                SpriteViewContainer(scene: scene)
                    .ignoresSafeArea()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {
                        isPause = true
                    } label: {
                        Image(.pauseIconIE)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                }
                
            }
            
            if isPause {
                ZStack {
                    
                        
                    VStack {
                        Button {
                            isPause = false
                        } label: {
                           Text("RESUME")
                        }
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("MENU")
                        }
                    }
                }.frame(height: 262)
            }
            
        }.background(
            ZStack {
                Image(.appBgIE)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
            }
            
        )
    }
}

#Preview {
    BirdsGameView(difficulty: .hard)
}
