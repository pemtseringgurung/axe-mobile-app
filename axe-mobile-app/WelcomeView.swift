//
//  WelcomeView.swift
//  axe-mobile-app
//
//  Created by Pem Tsering Gurung on 12/6/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showSignIn = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    // Background Image
                    Image("WelcomeBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .overlay(Color.black.opacity(0.3))
                    
                    // Main Content Stack
                    VStack(spacing: 0) {
                        Spacer()
                        
                        // CENTERED CONTENT
                        VStack(spacing: 20) {
                            // Logo + "axe" centered above title
                            HStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("axe")
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                            }
                            .padding(.bottom, 16)
                            
                            Text("Budget smarter.\nSpend better.")
                                .font(.system(size: 40, weight: .black))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            
                            Text("A smarter way to manage your spending habits.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(nil)
                                .padding(.horizontal, 40)
                            
                            NavigationLink(destination: SignInView()) {
                                Text("Get Started Free")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(Color(red: 207/255, green: 255/255, blue: 4/255))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 16)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        Spacer()
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
}
