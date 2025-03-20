//
//  SettingsModel.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 20.03.2025.
//


import SwiftUI

class SettingsViewModelIE: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true
    @AppStorage("vibraEnabled") var vibraEnabled: Bool = true
}
