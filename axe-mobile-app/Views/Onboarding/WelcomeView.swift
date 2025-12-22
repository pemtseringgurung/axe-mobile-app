//
//  WelcomeView.swift
//  axe-mobile-app
//
//  Minimal dark welcome screen
//

import SwiftUI

struct WelcomeView: View {
    @Binding var showAuth: Bool
    @Binding var isNewUser: Bool
    
    // Match app colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Section
                VStack(spacing: 28) {
                    // Logo circle
                    Circle()
                        .stroke(accent, lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(accent)
                        )
                    
                    VStack(spacing: 10) {
                        Text("axe")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .tracking(-0.5)
                            .foregroundColor(.white)
                        
                        Text("Budget better, spend smarter")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                Spacer()
                
                // Bottom Buttons
                VStack(spacing: 16) {
                    // Get Started
                    Button(action: {
                        isNewUser = true
                        showAuth = true
                    }) {
                        Text("Get Started")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(accent)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 24)
                    
                    // Sign in
                    Button(action: {
                        isNewUser = false
                        showAuth = true
                    }) {
                        Text("Already have an account")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Terms
                    Text("By continuing, you agree to our Terms and Privacy Policy")
                        .font(.system(size: 11))
                        .foregroundColor(.gray.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    WelcomeView(showAuth: .constant(false), isNewUser: .constant(true))
}
