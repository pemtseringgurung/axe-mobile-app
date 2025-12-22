//
//  AuthService.swift
//  axe-mobile-app
//
//  Handles authentication flows: Email and Google
//

import Foundation
import SwiftUI
import Combine
import Supabase
import Auth

// MARK: - Auth State
@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var userEmail: String? = nil
    @Published var userId: UUID? = nil
    
    private var authStateTask: Task<Void, Never>?
    
    private init() {
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateTask = Task {
            for await (event, session) in SupabaseService.shared.client.auth.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .initialSession, .signedIn:
                        if let session = session {
                            self.isAuthenticated = true
                            self.userEmail = session.user.email
                            self.userId = session.user.id
                        } else {
                            self.isAuthenticated = false
                            self.userEmail = nil
                            self.userId = nil
                        }
                    case .signedOut:
                        self.isAuthenticated = false
                        self.userEmail = nil
                        self.userId = nil
                    default:
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await SupabaseService.shared.client.auth.signIn(
                email: email,
                password: password
            )
            isAuthenticated = true
            userEmail = session.user.email
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await SupabaseService.shared.client.auth.signUp(
                email: email,
                password: password,
                data: ["full_name": .string(fullName)]
            )
            isAuthenticated = true
            userEmail = response.user.email
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await SupabaseService.shared.client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: URL(string: "axe://auth-callback")
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    func signOut() async {
        isLoading = true
        
        do {
            try await SupabaseService.shared.client.auth.signOut()
            isAuthenticated = false
            userEmail = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Handle OAuth Callback URL
    func handleAuthCallback(url: URL) async {
        do {
            try await SupabaseService.shared.client.auth.session(from: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
