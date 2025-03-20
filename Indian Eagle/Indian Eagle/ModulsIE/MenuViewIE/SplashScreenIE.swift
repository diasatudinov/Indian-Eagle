import SwiftUI

struct SplashScreenIE: View {
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                VStack {
                    Spacer()
                    ZStack {
                        VStack(spacing: -10) {
                            Text("Loading")
                                .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ?  32:16, weight: .bold))
                                .foregroundStyle(.orange)
                                .textCase(.uppercase)
                            HStack {
                                Spacer()
                                ZStack {
                                    Image(.loadingBgIE)
                                        .resizable()
                                        .scaledToFit()
                                    
                                    Image(.loaderIE)
                                        .resizable()
                                        .scaledToFit()
                                        .mask(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: (geometry.size.width * progress))
                                                .animation(.easeInOut, value: progress)
                                        }
                                        .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 40:20)
                                    
                                }.frame(height: DeviceInfoIE.shared.deviceType == .pad ? 76:38)
                                Spacer()
                            }
                        }
                    }
                    .foregroundColor(.black)
                    .padding(.bottom, DeviceInfoIE.shared.deviceType == .pad ? 50:25)
                }
            }.background(
                Image(.loaderBgIE)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            )
            .onAppear {
                startTimer()
            }
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        progress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { timer in
            if progress < 1 {
                progress += DeviceInfoIE.shared.deviceType == .pad ? 0.005:0.003
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    SplashScreenIE()
}
