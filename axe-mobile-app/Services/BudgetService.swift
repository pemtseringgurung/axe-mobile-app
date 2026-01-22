//
//  BudgetService.swift
//  axe-mobile-app
//
//  Service for managing budgets and categories
//

import Foundation
import SwiftUI
import Combine
import Supabase

final class BudgetService: ObservableObject {
    static let shared = BudgetService()
    
    @Published var categories: [Category] = Category.defaults
    @Published var budgets: [BudgetWithCategory] = []
    @Published var totalBudget: Double = 0
    @Published var totalSpent: Double = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    // MARK: - Load Categories
    func loadCategories() async {
        do {
            let response: [Category] = try await client
                .from("categories")
                .select()
                .execute()
                .value
            
            await MainActor.run {
                self.categories = response
            }
        } catch {
            print("Failed to load categories: \(error)")
            await MainActor.run {
                self.categories = Category.defaults
            }
        }
    }
    
    // MARK: - Load Budgets for Current Month
    func loadBudgets(userId: UUID) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        
        do {
            let response: [Budget] = try await client
                .from("budgets")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("month", value: month)
                .eq("year", value: year)
                .execute()
                .value
            
            // Map budgets to categories
            var budgetsWithCategories: [BudgetWithCategory] = []
            var total: Double = 0
            
            for budget in response {
                let category = categories.first { $0.id == budget.categoryId }
                let bwc = BudgetWithCategory(budget: budget, category: category, spent: 0)
                budgetsWithCategories.append(bwc)
                total += budget.amount + budget.rolloverAmount
            }
            
            await MainActor.run {
                self.budgets = budgetsWithCategories
                self.totalBudget = total
                self.isLoading = false
            }
            
        } catch {
            print("Failed to load budgets: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to load budgets"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Create or Update Budget
    func saveBudget(userId: UUID, categoryId: UUID?, amount: Double, rolloverEnabled: Bool = false) async -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        
        do {
            // For overall monthly budget (no category), delete existing first
            // This prevents duplicates since NULL category_id doesn't work with upsert
            if categoryId == nil {
                try await client
                    .from("budgets")
                    .delete()
                    .eq("user_id", value: userId.uuidString)
                    .is("category_id", value: nil)
                    .eq("month", value: month)
                    .eq("year", value: year)
                    .execute()
            }
            
            let input = BudgetInput(
                userId: userId,
                categoryId: categoryId,
                amount: amount,
                month: month,
                year: year,
                rolloverEnabled: rolloverEnabled,
                rolloverAmount: 0
            )
            
            if categoryId != nil {
                // Category-specific budgets can use upsert
                try await client
                    .from("budgets")
                    .upsert(input, onConflict: "user_id,category_id,month,year")
                    .execute()
            } else {
                // Overall budget - just insert (we already deleted old one)
                try await client
                    .from("budgets")
                    .insert(input)
                    .execute()
            }
            
            await loadBudgets(userId: userId)
            return true
        } catch {
            print("Failed to save budget: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to save budget"
            }
            return false
        }
    }
    
    // MARK: - Delete Budget
    func deleteBudget(budgetId: UUID, userId: UUID) async -> Bool {
        do {
            try await client
                .from("budgets")
                .delete()
                .eq("id", value: budgetId.uuidString)
                .execute()
            
            await loadBudgets(userId: userId)
            return true
        } catch {
            print("Failed to delete budget: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to delete budget"
            }
            return false
        }
    }
    
    // MARK: - Get Total Remaining
    var totalRemaining: Double {
        totalBudget - totalSpent
    }
}
