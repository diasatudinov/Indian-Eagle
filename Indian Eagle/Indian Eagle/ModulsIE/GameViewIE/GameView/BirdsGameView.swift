import SwiftUI
import SpriteKit

struct BirdsGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var shopVM: ShopViewModelIE
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
                if let currentTeamItems = shopVM.currentTeamItem {
                    SpriteViewContainer(scene: gameScene, gameWin: $isGameWin, moves: $moves, difficulty: difficulty, birds: currentTeamItems.images)
                        .ignoresSafeArea()
                }
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
                                    .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 30:15, weight: .bold))
                                    .foregroundStyle(.appBrown)
                            }.padding(DeviceInfoIE.shared.deviceType == .pad ? 16:8)
                            Spacer()
                        }
                    }.frame(width: DeviceInfoIE.shared.deviceType == .pad ? 140:70, height: DeviceInfoIE.shared.deviceType == .pad ? 140:70)
                    
                    
                    Button {
                        isPause = true
                        print("difficulty: \(difficulty)")
                    } label: {
                        Image(.pauseIconIE)
                            .resizable()
                            .scaledToFit()
                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
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
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 160:80)
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
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                        }
                        
                       
                        HStack(spacing: DeviceInfoIE.shared.deviceType == .pad ? 60:30) {
                            Button {
                                restartGame()
                            } label: {
                                Image(.restartLevelIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 160:80)
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Image(.restartIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 160:80)
                            }
                        }
                    }
                }.frame(width: DeviceInfoIE.shared.deviceType == .pad ? 640:320, height: DeviceInfoIE.shared.deviceType == .pad ? 524:262)
            }
            
            if isGameLose {
                ZStack {
                    Image(.loseBgIE)
                        .resizable()
                        .scaledToFit()
                        
                    VStack {
                        
                        
                       
                        HStack(spacing: DeviceInfoIE.shared.deviceType == .pad ? 60:30) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                
                            } label: {
                                Image(.homeIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Image(.restartIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 160:80)
                            }
                        }
                    }.padding(.top, DeviceInfoIE.shared.deviceType == .pad ? 140:70)
                }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 724:362)
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
                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                       
                        HStack(spacing: DeviceInfoIE.shared.deviceType == .pad ? 60:30) {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                                
                            } label: {
                                Image(.homeIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                            }
                            
                            Button {
                                restartGame()
                            } label: {
                                Image(.nextGameIconBtn)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 160:80)
                            }
                        }
                    }.padding(.top, DeviceInfoIE.shared.deviceType == .pad ? 140:70)
                }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 724:362)
            }
            }
            
        }.background(
            ZStack {
                Image(shopVM.currentSetItem?.images.first ?? "")
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
    BirdsGameView(shopVM: ShopViewModelIE(), difficulty: .hard)
}
