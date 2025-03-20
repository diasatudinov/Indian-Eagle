import SwiftUI

struct ShopViewIE: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var user = IEUser.shared
    
    @State private var itemType: ItemType = .team
    @ObservedObject var viewModel: ShopViewModelIE
    
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack {
            let chunksTeam = viewModel.shopTeamItems.chunked(into: 3)
            let chunksSet = viewModel.shopSetItems.chunked(into: 3)
            VStack {
                Spacer()
                ZStack {
                    
                    HStack {
                        ZStack {
                            Image(itemType == .team ? .greenSelectedBg: .nonSelectedBg)
                                .resizable()
                                .scaledToFit()
                            VStack {
                                Button {
                                    currentPage = 0
                                    itemType = .team
                                } label: {
                                    if itemType == .team {
                                        Image(.birdsIconIE)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                                    } else {
                                        
                                        Image(.birdsIconIE)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                                            .colorMultiply(.black.opacity(0.5))
                                    }
                                }
                                .padding(.top)
                                Spacer()
                            }
                        }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 540:270)
                            .offset(y: DeviceInfoIE.shared.deviceType == .pad ? -200:-100)
                        ZStack {
                            Image(itemType == .set ? .greenSelectedBg: .nonSelectedBg)
                                .resizable()
                                .scaledToFit()
                            VStack {
                                Button {
                                    currentPage = 0
                                    itemType = .set
                                } label: {
                                    if itemType == .set {
                                        Image(.setsIconIE)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                                    } else {
                                        
                                        Image(.setsIconIE)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 200:100)
                                            .colorMultiply(.black.opacity(0.5))
                                    }
                                }
                                .padding(.top)
                                Spacer()
                            }
                        }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 540:270)
                            .offset(y: DeviceInfoIE.shared.deviceType == .pad ? -200:-100)
                        Spacer()
                    }.padding(.leading, DeviceInfoIE.shared.deviceType == .pad ? 140:70)
                    
                    Image(.shopBgIE)
                        .resizable()
                        .scaledToFit()
                    
                    HStack(spacing: DeviceInfoIE.shared.deviceType == .pad ? 100:50) {
                        
                        
                        if itemType == .team {
                            ForEach(chunksTeam[currentPage], id: \.self) { team in
                                ZStack {
                                    Image("itemBgIE")
                                        .resizable()
                                        .scaledToFit()
                                        
                                    VStack {
                                        Text(team.name)
                                            .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 32:16, weight: .bold))
                                            .foregroundStyle(.appYellow)
                                        Image(team.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 260:130)
                                    }
                                    
                                    if let currentTeam = viewModel.currentTeamItem, currentTeam.name == team.name {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(.selectedIcon)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                            }
                                        }.padding(DeviceInfoIE.shared.deviceType == .pad ? 20:10)
                                    }
                                    Image(.priceIconIE)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                        .opacity(viewModel.boughtItems.contains(where: {$0.name == team.name}) ? 0:1)
                                }.frame(width: DeviceInfoIE.shared.deviceType == .pad ? 300:150, height: DeviceInfoIE.shared.deviceType == .pad ? 400:200)
                                    .onTapGesture {
                                        if viewModel.boughtItems.contains(where: {$0.name == team.name}) {
                                            viewModel.currentTeamItem = team
                                        } else {
                                            if user.birds >= 100 {
                                                user.minusUserBirds(for: 100)
                                                viewModel.boughtItems.append(team)
                                            }
                                        }
                                        
                                    }
                            }
                        } else {
                            ForEach(chunksSet[currentPage], id: \.self) { set in
                                ZStack {
                                    Image("itemBgIE")
                                        .resizable()
                                        .scaledToFit()
                                        
                                    VStack {
                                        Text(set.name)
                                            .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 32:16, weight: .bold))
                                            .foregroundStyle(.appYellow)
                                        Image(set.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 280:140)
                                    }
                                    
                                    if let currentSet = viewModel.currentSetItem, currentSet.name == set.name {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                Image(.selectedIcon)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                            }
                                        }.padding(DeviceInfoIE.shared.deviceType == .pad ? 20:10)
                                    }
                                    Image(.priceIconIE)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                        .opacity(viewModel.boughtItems.contains(where: {$0.name == set.name}) ? 0:1)
                                }.frame(width: DeviceInfoIE.shared.deviceType == .pad ? 300:150, height: DeviceInfoIE.shared.deviceType == .pad ? 400:200)
                                    .onTapGesture {
                                        if viewModel.boughtItems.contains(where: {$0.name == set.name}) {
                                            viewModel.currentSetItem = set
                                        } else {
                                            if user.birds >= 100 {
                                                user.minusUserBirds(for: 100)
                                                viewModel.boughtItems.append(set)
                                            }
                                        }
                                        
                                    }
                            }
                        }
                    }
                    HStack {
                        Button(action: {
                            if currentPage > 0 {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                        }) {
                            Image(.arrowIE)
                                .resizable()
                                .scaledToFit()
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                .rotationEffect(.degrees(180))
                            
                        }
                        .disabled(currentPage == 0)
                        
                        Spacer()
                        
                        
                        Button(action: {
                            if currentPage < chunksTeam.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }) {
                            Image(.arrowIE)
                                .resizable()
                                .scaledToFit()
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                        }
                        .disabled(currentPage >= chunksTeam.count - 1)
                    }
                    .padding(.horizontal, DeviceInfoIE.shared.deviceType == .pad ? -32:-16)
                            
                    
                }.frame(width: DeviceInfoIE.shared.deviceType == .pad ? UIScreen.main.bounds.width - 200 : UIScreen.main.bounds.width - 170, height: DeviceInfoIE.shared.deviceType == .pad ? 540:270)
            }
            
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
                    
                    Spacer()
                    
                    FLBirdsView()
                }
                Spacer()
            }.padding()
            
            
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
    ShopViewIE(viewModel: ShopViewModelIE())
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { startIndex in
            let endIndex = Swift.min(startIndex + size, count)
            return Array(self[startIndex..<endIndex])
        }
    }
}
