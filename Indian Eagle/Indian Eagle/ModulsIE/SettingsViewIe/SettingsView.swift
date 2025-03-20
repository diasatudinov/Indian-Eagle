import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var settings: SettingsViewModelIE

    var body: some View {
        ZStack {
                        
            VStack {
                ZStack {
                    Image(.settingsBgIE)
                        .resizable()
                        .scaledToFit()
                        .padding(DeviceInfoIE.shared.deviceType == .pad ? 40:20)
                    
                    VStack {
                        HStack {
                            HStack {
                                
                                Image(.soundIconIE)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                VStack {
                                    Text("Sound")
                                        .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 32:16, weight: .bold))
                                        .textCase(.uppercase)
                                        .foregroundStyle(.appBrown)
                                    Button {
                                        settings.soundEnabled.toggle()
                                    } label: {
                                        if settings.soundEnabled {
                                            Image(.onIE)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                        } else {
                                            Image(.offIE)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                
                                Image(.musicIconIE)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                VStack {
                                    Text("Music")
                                        .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 32:16, weight: .bold))
                                        .textCase(.uppercase)
                                        .foregroundStyle(.appBrown)
                                    Button {
                                        settings.musicEnabled.toggle()
                                        
                                    } label: {
                                        if settings.musicEnabled {
                                            Image(.onIE)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                        } else {
                                            Image(.offIE)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                        }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            
                            Image(.vibraIconIE)
                                .resizable()
                                .scaledToFit()
                                .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                            VStack {
                                Text("Vibration")
                                    .font(.system(size: DeviceInfoIE.shared.deviceType == .pad ? 32:16, weight: .bold))
                                    .textCase(.uppercase)
                                    .foregroundStyle(.appBrown)
                                Button {
                                    settings.vibraEnabled.toggle()
                                } label: {
                                    if settings.vibraEnabled {
                                        Image(.onIE)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                    } else {
                                        Image(.offIE)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: DeviceInfoIE.shared.deviceType == .pad ? 100:50)
                                    }
                                }
                            }
                        }
                    }
                }
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
        
    }
}

#Preview {
    SettingsView(settings: SettingsViewModelIE())
}
