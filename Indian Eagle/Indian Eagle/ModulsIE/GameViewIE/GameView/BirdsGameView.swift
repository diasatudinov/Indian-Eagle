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
    @State private var isGameLose = false
    @State private var isGameWin = false
    @State private var moves = 0
    @State private var gameScene: GameScene = {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        // Default difficulty can be overwritten in onAppear
        return scene
    }()
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                SpriteViewContainer(scene: gameScene, gameWin: $isGameWin, moves: $moves, difficulty: difficulty)
                    .ignoresSafeArea()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    ZStack {
                        Image(.movesBg)
                            .resizable()
                            .scaledToFit()
                            
                        VStack {
                            HStack {
                                Spacer()
                                Text("\(moves)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.appBrown)
                            }.padding(8)
                            Spacer()
                        }
                    }.frame(width: 70, height: 70)
                    
                    
                    Button {
                        isPause = true
                        print("difficulty: \(difficulty)")
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
                    Image(.pauseBgIE)
                        .resizable()
                        .scaledToFit()
                        
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                isPause = false
                                
                            } label: {
                                Image(.closeIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                        }
                        Spacer()
                    }
                    VStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                            
                        } label: {
                            Image(.homeIconBtn)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        }
                        
                       
                        HStack(spacing: 30) {
                            Button {
                                restartGame()
                            } label: {
                                Image(.restartLevelIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Image(.restartIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                        }
                    }
                }.frame(width: 320, height: 262)
            }
            
            if isGameLose {
                ZStack {
                    Image(.loseBgIE)
                        .resizable()
                        .scaledToFit()
                        
                    VStack {
                        
                        
                       
                        HStack(spacing: 30) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                
                            } label: {
                                Image(.homeIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Image(.restartIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                        }
                    }.padding(.top, 70)
                }.frame(height: 362)
            }
            
            if isGameWin {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
               
                ZStack {
                    
                    Image(.winBgIE)
                        .resizable()
                        .scaledToFit()
                        
                    VStack {
                        Spacer()
                        Image(.bonusesIconIE)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                       
                        HStack(spacing: 30) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                
                            } label: {
                                Image(.homeIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Image(.nextGameIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                            }
                        }
                    }.padding(.top, 70)
                }.frame(height: 362)
            }
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
    
    private func restartGame() {
        gameScene.restartGame()
        
        moves = 0
        isPause = false
        isGameLose = false
        isGameWin = false
    }
}

#Preview {
    BirdsGameView(difficulty: .hard)
}
