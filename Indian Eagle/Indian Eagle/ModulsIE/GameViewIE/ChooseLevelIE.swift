//
//  ChooseLevelIE.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI

struct ChooseLevelIE: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var showLevel = false
    @State var difficulty: Difficulty?
    private var difficultyArray: [Difficulty] = [.easy, .hard, .medium]
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(.backIconIE)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)
                    }
                    FLBirdsView()
                    
                    Spacer()
                    
                    IEStarsView()
                    
                }
                Spacer()
                HStack {
                    Button {
                        difficulty = nil
                        DispatchQueue.main.async {
                            difficulty = .easy
                        }
                            showLevel = true
                        
                    } label: {
                        Image(.easyIcon)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    
                    Button {
                        difficulty = nil
                        DispatchQueue.main.async {
                            difficulty = .medium
                        }
                        showLevel = true
                    } label: {
                        Image(.mediumIcaon)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    
                    Button {
                        difficulty = nil
                        DispatchQueue.main.async {
                            difficulty = .hard
                        }
                        showLevel = true
                    } label: {
                        Image(.hardIcon)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                    
                    Button {
                        DispatchQueue.main.async {
                            difficulty = difficultyArray.randomElement()
                        }
                        showLevel = true
                    } label: {
                        Image(.randomLevelIcon)
                            .resizable()
                            .scaledToFit()
                            .padding()
                    }
                }
                
                
                Spacer()
                
                
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
        .fullScreenCover(isPresented: $showLevel) {
            if let difficulty = difficulty {
                BirdsGameView(difficulty: difficulty)
            }
        }
        
    }
}

#Preview {
    ChooseLevelIE()
}
