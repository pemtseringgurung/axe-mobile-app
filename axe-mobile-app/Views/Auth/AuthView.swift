//
//  AuthView.swift
//  axe-mobile-app
//
//  Minimal dark auth view
//

import SwiftUI

struct AuthView: View {
    @ObservedObject private var authService = AuthService.shared
    @Binding var showAuth: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var isNewUser: Bool
    
    // Match app colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    init(showAuth: Binding<Bool>, isNewUser: Bool = false) {
        _showAuth = showAuth
        _isNewUser = State(initialValue: isNewUser)
    }
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: { showAuth = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Logo
                        Circle()
                            .stroke(accent, lineWidth: 2)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(accent)
                            )
                            .padding(.top, 32)
                            .padding(.bottom, 24)
                        
                        // Title
                        Text(isNewUser ? "Create account" : "Welcome back")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.bottom, 6)
                        
                        Text(isNewUser ? "Start your journey to smarter spending" : "Sign in to continue")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.bottom, 32)
                        
                        // Error
                        if let error = authService.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red.opacity(0.8))
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)
                        }
                        
                        // Form fields
                        VStack(spacing: 16) {
                            if isNewUser {
                                AuthTextField(placeholder: "Full name", text: $fullName, accent: accent)
                            }
                            
                            AuthTextField(placeholder: "Email", text: $email, accent: accent, keyboardType: .emailAddress)
                            
                            AuthSecureField(placeholder: isNewUser ? "Create password" : "Password", text: $password, accent: accent)
                            
                            if isNewUser {
                                AuthSecureField(
                                    placeholder: "Confirm password",
                                    text: $confirmPassword,
                                    accent: accent,
                                    hasError: !confirmPassword.isEmpty && password != confirmPassword
                                )
                                
                                if !confirmPassword.isEmpty && password != confirmPassword {
                                    Text("Passwords don't match")
                                        .font(.system(size: 12))
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Main button
                        Button(action: submit) {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text(isNewUser ? "Create Account" : "Sign In")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? accent : Color.white.opacity(0.2))
                        .cornerRadius(14)
                        .disabled(!canSubmit || authService.isLoading)
                        .padding(.horizontal, 24)
                        .padding(.top, 28)
                        
                        // Divider
                        HStack(spacing: 16) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                            Text("or")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        
                        // Social buttons
                        VStack(spacing: 12) {
                            SocialButton(icon: "g.circle.fill", title: "Continue with Google") {
                                Task { await authService.signInWithGoogle() }
                            }
                            
                            SocialButton(icon: "apple.logo", title: "Continue with Apple") {
                                // TODO: Apple Sign In
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Toggle
                        Button(action: {
                            withAnimation {
                                isNewUser.toggle()
                                authService.clearError()
                            }
                        }) {
                            Text(isNewUser ? "Already have an account? Sign in" : "Don't have an account? Sign up")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onAppear { authService.clearError() }
    }
    
    private var canSubmit: Bool {
        if isNewUser {
            return !email.isEmpty && !password.isEmpty && !fullName.isEmpty && password == confirmPassword && !confirmPassword.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func submit() {
        Task {
            if isNewUser {
                await authService.signUp(email: email, password: password, fullName: fullName)
            } else {
                await authService.signIn(email: email, password: password)
            }
        }
    }
}

// MARK: - Auth TextField
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    let accent: Color
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.3))
                }
                
                TextField("", text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
            }
            .padding(.vertical, 14)
            
            Rectangle()
                .fill(text.isEmpty ? Color.white.opacity(0.15) : accent.opacity(0.5))
                .frame(height: 1)
        }
    }
}

// MARK: - Auth Secure Field
struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String
    let accent: Color
    var hasError: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.3))
                }
                
                SecureField("", text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 14)
            
            Rectangle()
                .fill(hasError ? Color.red.opacity(0.5) : (text.isEmpty ? Color.white.opacity(0.15) : accent.opacity(0.5)))
                .frame(height: 1)
        }
    }
}

// MARK: - Social Button
struct SocialButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

#Preview("Sign Up") {
    AuthView(showAuth: .constant(true), isNewUser: true)
}

#Preview("Sign In") {
    AuthView(showAuth: .constant(true), isNewUser: false)
}
