//
//  MediaPlayerAppApp.swift
//  MediaPlayerApp
//
//  Created by Devang Parmar on 21/04/26.
//

import SwiftUI

@main
struct MediaPlayerAppApp: App {
    @StateObject var userViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            if userViewModel.isLoggedIn {
                MainView()
                    .environmentObject(userViewModel)
            } else {
                LoginView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
