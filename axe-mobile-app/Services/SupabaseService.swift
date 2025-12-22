//
//  SupabaseService.swift
//  axe-mobile-app
//
//  Supabase client configuration
//

import Foundation
import Supabase

// MARK: - Supabase Configuration
// ⚠️ For production: Use environment variables or xcconfig files
enum SupabaseConfig {
    // Replace with your Supabase project URL
    static let url = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
    
    // Replace with your Supabase anon/public key
    static let anonKey = "YOUR_SUPABASE_ANON_KEY"
}

// MARK: - Supabase Client Singleton
class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }
}
