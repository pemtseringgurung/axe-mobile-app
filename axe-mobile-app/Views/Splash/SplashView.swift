//
//  SplashView.swift
//  axe-mobile-app
//
//  Minimal dark splash screen
//

import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    
    // Match app colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Logo with accent
                Image(systemName: "leaf.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(accent)
                    .scaleEffect(isAnimating ? 1.0 : 0.7)
                    .opacity(isAnimating ? 1.0 : 0.3)
                
                Text("axe")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .tracking(-0.5)
                    .foregroundColor(.white)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashView()
}
