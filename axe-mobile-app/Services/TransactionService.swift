//
//  TransactionService.swift
//  axe-mobile-app
//
//  Service for managing transactions via Supabase
//

import Foundation
import Supabase
import Combine

final class TransactionService: ObservableObject {
    static let shared = TransactionService()
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    // MARK: - Fetch Transactions
    func fetchTransactions(userId: UUID) async -> [Transaction] {
        await MainActor.run { self.isLoading = true }
        
        do {
            let response: [Transaction] = try await client
                .from("transactions")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("date", ascending: false)
                .execute()
                .value
            
            await MainActor.run { self.isLoading = false }
            return response
        } catch {
            print("Error fetching transactions: \(error)")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to load transactions"
            }
            return []
        }
    }
    
    // MARK: - Add Transaction
    func addTransaction(userId: UUID, amount: Double, categoryId: UUID?, description: String?, date: Date) async -> Transaction? {
        await MainActor.run { self.isLoading = true }
        
        struct NewTransaction: Encodable {
            let user_id: UUID
            let category_id: UUID?
            let amount: Double
            let description: String?
            let date: Date
        }
        
        let newTx = NewTransaction(
            user_id: userId,
            category_id: categoryId,
            amount: amount,
            description: description,
            date: date
        )
        
        do {
            let response: Transaction = try await client
                .from("transactions")
                .insert(newTx)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ Transaction saved to Supabase: \(response.id)")
            await MainActor.run { self.isLoading = false }
            return response
        } catch {
            print("❌ SUPABASE ERROR adding transaction:")
            print("   Error: \(error)")
            print("   User ID: \(userId)")
            print("   Amount: \(amount)")
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Failed to add transaction: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - Delete Transaction
    func deleteTransaction(id: UUID) async -> Bool {
        do {
            try await client
                .from("transactions")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            return true
        } catch {
            print("Error deleting transaction: \(error)")
            return false
        }
    }
}
