//
//  WelcomeView.swift
//  axe-mobile-app
//
//  Created by Pem Tsering Gurung on 12/6/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            // Background Image
            Image("WelcomeBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.3)) // Slight overlay for text readability
            
                // Top Navigation / Logo
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Text("axe")
                        .font(.title2)
                        .fontWeight(.heavy) // Made heavier
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60) // Increased top padding to ensure it clears dynamic islands/notches
                
                Spacer()
                
                // Centered Content
                VStack(spacing: 24) { // Slightly reduced spacing
                    Text("Budget smarter.\nSpend better.")
                        .font(.system(size: 42, weight: .black, design: .default)) // Slightly smaller to prevent edge touching
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    
                    Text("Break free from impulsive spending. A budgeting solution that addresses the behavioral patterns behind overspending, not just the numbers.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 32) // Ensure plenty of buffer
                        .minimumScaleFactor(0.8) // allow slight shrinking if needed
                    
                    // Call to Action
                    Button(action: {
                        print("Get Started Free Tapped")
                    }) {
                        Text("Get Started Free")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color(red: 207/255, green: 255/255, blue: 4/255)) // Neon Green
                            .clipShape(Capsule())
                    }
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.top, 10)
                }
                .padding(.bottom, 60)
                
                Spacer()
            }
        }
}

#Preview {
    WelcomeView()
}
