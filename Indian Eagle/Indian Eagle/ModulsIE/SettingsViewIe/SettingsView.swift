//
//  SettingsView.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 19.03.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

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
    SettingsView()
}
