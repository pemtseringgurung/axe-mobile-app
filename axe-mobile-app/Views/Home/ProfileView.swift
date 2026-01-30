//
//  ProfileView.swift
//  axe-mobile-app
//
//  Minimal profile sheet with logout
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    
    // Minimal colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Profile header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(firstName.prefix(1)).uppercased())
                                    .font(.spaceGroteskBold(28))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(firstName)
                                .font(.spaceGroteskBold(22))
                                .foregroundColor(.white)
                            
                            Text(authService.userEmail ?? "")
                                .font(.spaceGrotesk(14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 32)
                    
                    // Menu items
                    VStack(spacing: 0) {
                        MenuItem(icon: "person", title: "Account", action: {})
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 56)
                        
                        MenuItem(icon: "bell", title: "Notifications", action: {})
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 56)
                        
                        MenuItem(icon: "shield", title: "Privacy", action: {})
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.leading, 56)
                        
                        MenuItem(icon: "questionmark.circle", title: "Help", action: {})
                    }
                    
                    Spacer()
                    
                    // Logout button
                    Button(action: logout) {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 16, weight: .light))
                            
                            Text("Log Out")
                                .font(.spaceGroteskMedium(16))
                        }
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(bgColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }
    
    private var firstName: String {
        guard let email = authService.userEmail else { return "User" }
        let name = email.components(separatedBy: "@").first ?? "User"
        return name.capitalized
    }
    
    private func logout() {
        Task {
            await authService.signOut()
            dismiss()
        }
    }
}

// MARK: - Menu Item
struct MenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.white.opacity(0.6))
                    )
                
                Text(title)
                    .font(.spaceGroteskMedium(16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService.shared)
}
