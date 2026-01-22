//
//  axe_mobile_appApp.swift
//  axe-mobile-app
//
//  Main App entry point with splash, welcome, and auth flow
//

import SwiftUI

@main
struct axe_mobile_appApp: App {
    @ObservedObject private var authService = AuthService.shared
    
    @State private var showSplash = true
    @State private var showAuth = false
    @State private var isNewUser = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if authService.isAuthenticated {
                    // Logged in - show home
                    HomeView()
                        .environmentObject(authService)
                        .transition(.opacity)
                } else if showSplash {
                    // Initial launch - show splash
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSplash = false
                                }
                            }
                        }
                } else if showAuth {
                    // Auth screen
                    AuthView(showAuth: $showAuth, isNewUser: isNewUser)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    // Welcome screen
                    WelcomeView(showAuth: $showAuth, isNewUser: $isNewUser)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSplash)
            .animation(.easeInOut(duration: 0.3), value: showAuth)
            .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
            .onOpenURL { url in
                Task {
                    await authService.handleAuthCallback(url: url)
                }
            }
        }
    }
}
