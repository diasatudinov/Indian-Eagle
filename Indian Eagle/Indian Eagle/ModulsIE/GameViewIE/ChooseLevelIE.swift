import SwiftUI

struct ChooseLevelIE: View {
    @ObservedObject var shopVM: ShopViewModelIE
    @Environment(\.presentationMode) var presentationMode
    @State private var showLevel = false
    
    @State var difficulty: Difficulty?
    var difficultyArray: [Difficulty] = [.easy, .hard, .medium]
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
                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 140:70)
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
                Image(shopVM.currentSetItem?.images.first ?? "")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
            }
            
        )
        .fullScreenCover(isPresented: $showLevel) {
            if let difficulty = difficulty {
                BirdsGameView(shopVM: shopVM, difficulty: difficulty)
            }
        }
        
    }
}

#Preview {
    ChooseLevelIE(shopVM: ShopViewModelIE())
}
