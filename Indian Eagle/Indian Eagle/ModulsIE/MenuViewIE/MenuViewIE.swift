//
//  MenuViewIE.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 18.03.2025.
//

import SwiftUI

struct MenuViewIE: View {
    @State private var showAIGame = false
    @State private var showShop = false
    @State private var showSettings = false
    
//    @StateObject var shopVM = SVM()
//    @StateObject var settingsVM = SM()
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        
                        FLBirdsView()
                        
                        Spacer()
                        
                        IEStarsView()
                        
                    }
                    Spacer()
                    
                    HStack {
                        Button {
                            showAIGame = true
                        } label: {
                            Image(.playIconIE)
                                .resizable()
                                .scaledToFit()
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ?400:200)
                        }
                        
                    }
                    
                    Spacer()
                    HStack {
                        Button {
                            showShop = true
                        } label: {
                            Image(.shopIconIE)
                                .resizable()
                                .scaledToFit()
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 180:90)
                        }
                        Spacer()
                        Button {
                            showSettings = true
                        } label: {
                            Image(.settingsIconIE)
                                .resizable()
                                .scaledToFit()
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 180:90)
                        }
                        
                    }
                }.padding()
            }
            .background(
                ZStack {
                    Image(.appBgIE)
                        .resizable()
                        .edgesIgnoringSafeArea(.all)
                        .scaledToFill()
                }
                
            )
//            .onAppear {
//                if settingsVM.musicEnabled {
//                    MusicPlayer.shared.playBackgroundMusic()
//                }
//            }
//            .onChange(of: settingsVM.musicEnabled) { enabled in
//                if enabled {
//                    MusicPlayer.shared.playBackgroundMusic()
//                } else {
//                    MusicPlayer.shared.stopBackgroundMusic()
//                }
//            }
            .fullScreenCover(isPresented: $showAIGame) {
                ChooseLevelIE()
            }
            .fullScreenCover(isPresented: $showShop) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            
        }
        
        
    }
    
}

#Preview {
    MenuViewIE()
}
