//
//  Indian_EagleApp.swift
//  Indian Eagle
//
//  Created by Dias Atudinov on 17.03.2025.
//

import SwiftUI

@main
struct Indian_EagleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
    }
}
