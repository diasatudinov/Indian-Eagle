import SwiftUI

struct IEStarsView: View {
    @StateObject var user = IEUser.shared
    var body: some View {
        ZStack {
            Image(.starsBgIE)
                .resizable()
                .scaledToFit()
                
            
            Text("\(user.stars)")
                .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 40:20, weight: .black))
                .foregroundStyle(.appBrown)
                .textCase(.uppercase)
                .offset(x: DeviceInfoIE.shared.deviceType == .pad ? -40:-20, y: DeviceInfoIE.shared.deviceType == .pad ? 10:5)
        }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 140:70)
    }
}

#Preview {
    IEStarsView()
}
