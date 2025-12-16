//
//  SignInView.swift
//  axe-mobile-app
//
//  Created by Pem Tsering Gurung on 12/6/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background Image (same as Welcome)
                Image("WelcomeBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(Color.black.opacity(0.4))
                
                VStack(spacing: 0) {
                    // Back Button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Sign In Content
                    VStack(spacing: 24) {
                        // Logo
                        HStack(spacing: 8) {
                            Image(systemName: "leaf.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("axe")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                        }
                        .padding(.bottom, 8)
                        
                        Text("Sign In")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal, 24)
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            SecureField("", text: $password)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        
                        // Sign In Button
                        Button(action: {
                            print("Sign In Tapped")
                        }) {
                            Text("Sign In")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 207/255, green: 255/255, blue: 4/255))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
                        // Create Account Link
                        HStack {
                            Text("First time user?")
                                .foregroundColor(.white.opacity(0.7))
                            Button(action: {
                                print("Create Account Tapped")
                            }) {
                                Text("Create account")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 207/255, green: 255/255, blue: 4/255))
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
}

#Preview {
    SignInView()
}
