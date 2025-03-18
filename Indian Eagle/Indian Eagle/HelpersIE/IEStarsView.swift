//
//  FLBirdsView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 18.03.2025.
//


import SwiftUI

struct FLBirdsView: View {
    @StateObject var user = IEUser.shared
    var body: some View {
        ZStack {
            Image(.birdsBgIE)
                .resizable()
                .scaledToFit()
                
            
            Text("\(user.birds)")
                .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 40:20, weight: .black))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .offset(x: DeviceInfoIE.shared.deviceType == .pad ? 40:20, y: DeviceInfoIE.shared.deviceType == .pad ? 10:5)
        }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 140:70)
    }
}

#Preview {
    FLBirdsView()
}