//
//  HomeViewModel.swift
//  axe-mobile-app
//
//  ViewModel for home dashboard - manages budget and transaction data
//

import Foundation
import SwiftUI
import Combine

// MARK: - Display Models
struct CategoryBudgetItem: Identifiable {
    let id: UUID
    let name: String
    let icon: String // SF Symbol name
    let color: Color
    var budget: Double
    var spent: Double
    var isDefault: Bool = true // Default categories can't be deleted
}

struct TransactionDisplayItem: Identifiable {
    let id: UUID
    let title: String
    let amount: Double
    let categoryIcon: String
    let categoryColor: Color
    let dateString: String
    let date: Date
}

// MARK: - ViewModel
class HomeViewModel: ObservableObject {
    @Published var totalBudget: Double = 0
    @Published var totalSpent: Double = 0
    @Published var categories: [CategoryBudgetItem] = []
    @Published var transactions: [TransactionDisplayItem] = []
    @Published var isLoading = false
    
    private var userId: UUID?
    private var rawTransactions: [Transaction] = []
    
    // Services
    private let transactionService = TransactionService.shared
    private let budgetService = BudgetService.shared
    
    // MARK: - Computed Properties
    var hasBudget: Bool { totalBudget > 0 }
    
    var remaining: Double { max(0, totalBudget - totalSpent) }
    
    var budgetProgress: Double {
        guard totalBudget > 0 else { return 0 }
        return min(totalSpent / totalBudget, 1.0)
    }
    
    var isOverBudget: Bool { totalSpent > totalBudget }
    
    var daysLeftInMonth: Int {
        let calendar = Calendar.current
        let today = Date()
        guard let range = calendar.range(of: .day, in: .month, for: today) else { return 0 }
        let currentDay = calendar.component(.day, from: today)
        return range.count - currentDay
    }
    
    var safeToSpendToday: Double {
        guard daysLeftInMonth > 0 else { return remaining }
        return remaining / Double(max(1, daysLeftInMonth))
    }
    
    var dailyAverage: Double {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: Date())
        guard day > 0 else { return 0 }
        return totalSpent / Double(day)
    }
    
    var projectedMonthlySpend: Double {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: Date()) else { return 0 }
        return dailyAverage * Double(range.count)
    }
    
    var isOnTrack: Bool { projectedMonthlySpend <= totalBudget || totalBudget == 0 }
    
    var insightMessage: String {
        if !hasBudget {
            return "Set up your budget to get personalized insights."
        }
        
        if isOnTrack {
            return "You're doing great! At this pace, you'll stay within budget. Keep up the good spending habits."
        } else {
            let over = projectedMonthlySpend - totalBudget
            return "Heads up — you're projected to exceed your budget by $\(String(format: "%.0f", over)). Consider reducing spending."
        }
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }
    
    func firstName(from email: String?) -> String {
        guard let email = email else { return "there" }
        let name = email.components(separatedBy: "@").first ?? "there"
        return name.capitalized
    }
    
    // MARK: - Data Loading
    func loadData(userId: UUID) {
        self.userId = userId
        
        // Load transactions from local storage immediately (for fast UI)
        loadTransactionsLocally()
        
        // Setup dashboard with local data first
        setupDashboard()
        
        // Then load from Supabase
        Task {
            await MainActor.run { self.isLoading = true }
            
            // Load Categories from Supabase
            await budgetService.loadCategories()
            
            // Load Budgets from Supabase
            await budgetService.loadBudgets(userId: userId)
            
            // Load Transactions from Supabase
            let cloudTxs = await transactionService.fetchTransactions(userId: userId)
            
            await MainActor.run {
                // Use cloud budget
                self.totalBudget = budgetService.totalBudget
                
                // Use cloud transactions
                if !cloudTxs.isEmpty {
                    self.rawTransactions = cloudTxs
                    self.processTransactions()
                }
                
                self.setupDashboard()
                self.isLoading = false
            }
        }
    }
    
    private func processTransactions() {
        // Map raw transactions to display items
        self.transactions = rawTransactions.map { tx in
            let category = budgetService.categories.first { $0.id == tx.categoryId }
            let catName = category?.name ?? "Transaction"
            
            // Use description if it exists and is not empty, otherwise use category name
            let displayTitle = (tx.description?.isEmpty == false) ? tx.description! : catName
            
            return TransactionDisplayItem(
                id: tx.id,
                title: displayTitle,
                amount: tx.amount,
                categoryIcon: category?.icon ?? "square.grid.2x2.fill",
                categoryColor: Color(hex: category?.color ?? "#808080"),
                dateString: formatDate(tx.date),
                date: tx.date
            )
        }
        
        // Calculate total spent this month
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        self.totalSpent = rawTransactions
            .filter {
                calendar.component(.month, from: $0.date) == currentMonth &&
                calendar.component(.year, from: $0.date) == currentYear
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func setupDashboard() {
        // Calculate spending per category ID
        var categorySpending: [UUID: Double] = [:]
        for tx in rawTransactions {
            if let catId = tx.categoryId {
                categorySpending[catId, default: 0] += tx.amount
            }
        }
        
        // Always use actual categories for the bubble display
        // Don't use budget rows (which may have NULL category_id for overall budget)
        let allCategories = budgetService.categories.isEmpty ? Category.defaults : budgetService.categories
        
        // Get category-specific budgets (filter out overall budgets with nil category)
        let categoryBudgets = budgetService.budgets.filter { $0.category != nil }
        
        self.categories = allCategories.map { cat in
            // Find if there's a specific budget for this category
            let catBudget = categoryBudgets.first { $0.category?.id == cat.id }
            
            return CategoryBudgetItem(
                id: cat.id,
                name: cat.name,
                icon: cat.icon,
                color: Color(hex: cat.color),
                budget: catBudget?.budget.amount ?? 0,
                spent: categorySpending[cat.id] ?? 0,
                isDefault: cat.isDefault ?? true
            )
        }
    }
    
    // MARK: - Actions
    func setBudget(amount: Double) {
        guard let userId = userId else { return }
        self.totalBudget = amount
        setupDashboard()
        
        // Save to Supabase in background
        Task {
            let success = await budgetService.saveBudget(
                userId: userId,
                categoryId: nil,  // nil = total budget
                amount: amount,
                rolloverEnabled: false
            )
            if success {
                print("✅ Budget saved to Supabase")
            } else {
                print("❌ Failed to save budget to Supabase")
            }
        }
    }
    
    // MARK: - Category Budget Allocation
    var allocatedBudget: Double {
        categories.reduce(0) { $0 + $1.budget }
    }
    
    var unallocatedBudget: Double {
        max(0, totalBudget - allocatedBudget)
    }
    
    func setCategoryBudget(categoryId: UUID, amount: Double) {
        guard let userId = userId else { return }
        
        // Update local state immediately
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[index].budget = amount
        }
        
        // Save to Supabase in background
        Task {
            let success = await budgetService.saveBudget(
                userId: userId,
                categoryId: categoryId,
                amount: amount,
                rolloverEnabled: false
            )
            if success {
                print("✅ Category budget saved to Supabase")
            } else {
                print("❌ Failed to save category budget to Supabase")
            }
        }
    }
    
    // MARK: - Custom Category Management
    func addCategory(name: String, icon: String) {
        let newCategoryId = UUID()
        
        // Add to local state immediately
        let newCategory = CategoryBudgetItem(
            id: newCategoryId,
            name: name,
            icon: icon,
            color: Color(red: 185/255, green: 255/255, blue: 100/255), // Use accent color
            budget: 0,
            spent: 0,
            isDefault: false // Custom category can be deleted
        )
        categories.append(newCategory)
        
        // Save to Supabase in background
        Task {
            let success = await budgetService.addCategory(name: name, icon: icon)
            if success {
                print("✅ Custom category saved to Supabase")
            } else {
                print("❌ Failed to save custom category to Supabase")
            }
        }
    }
    
    func deleteCategory(categoryId: UUID) {
        // Remove from local state immediately
        categories.removeAll { $0.id == categoryId }
        
        // Delete from Supabase in background
        Task {
            let success = await budgetService.deleteCategory(categoryId: categoryId)
            if success {
                print("✅ Category deleted from Supabase")
            } else {
                print("❌ Failed to delete category from Supabase")
            }
        }
    }
    
    func addTransaction(amount: Double, categoryName: String, description: String, date: Date) {
        guard let userId = userId else { return }
        
        // Find category for display
        let category = budgetService.categories.first { $0.name == categoryName }
        
        let txId = UUID()
        
        // Create display item immediately
        let newTx = TransactionDisplayItem(
            id: txId,
            title: description.isEmpty ? categoryName : description,
            amount: amount,
            categoryIcon: category?.icon ?? "square.grid.2x2.fill",
            categoryColor: Color(hex: category?.color ?? "#808080"),
            dateString: "Today",
            date: date
        )
        
        // Also add to rawTransactions so category spending updates correctly
        let rawTx = Transaction(
            id: txId,
            userId: userId,
            categoryId: category?.id,
            amount: amount,
            description: description.isEmpty ? nil : description,
            date: date,
            createdAt: Date()
        )
        rawTransactions.insert(rawTx, at: 0)
        
        // Update UI immediately
        transactions.insert(newTx, at: 0)
        totalSpent += amount
        setupDashboard() // This now sees the new transaction in rawTransactions
        
        // Save to local storage
        saveTransactionsLocally()
        
        // Try to save to Supabase in background (don't block on it)
        Task {
            _ = await transactionService.addTransaction(
                userId: userId,
                amount: amount,
                categoryId: category?.id,
                description: description,
                date: date
            )
        }
    }
    
    // MARK: - Delete Transaction
    func deleteTransaction(id: UUID) {
        // Remove from local array immediately
        transactions.removeAll { $0.id == id }
        
        // Recalculate spent
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        self.totalSpent = transactions
            .filter {
                calendar.component(.month, from: $0.date) == currentMonth &&
                calendar.component(.year, from: $0.date) == currentYear
            }
            .reduce(0) { $0 + $1.amount }
        
        // Update local storage
        saveTransactionsLocally()
        
        // Delete from Supabase
        Task {
            _ = await transactionService.deleteTransaction(id: id)
        }
    }
    
    // MARK: - Update Transaction
    func updateTransaction(id: UUID, amount: Double, description: String) {
        // Update local array immediately
        if let index = transactions.firstIndex(where: { $0.id == id }) {
            let old = transactions[index]
            transactions[index] = TransactionDisplayItem(
                id: id,
                title: description.isEmpty ? old.title : description,
                amount: amount,
                categoryIcon: old.categoryIcon,
                categoryColor: old.categoryColor,
                dateString: old.dateString,
                date: old.date
            )
        }
        
        // Recalculate spent
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        self.totalSpent = transactions
            .filter {
                calendar.component(.month, from: $0.date) == currentMonth &&
                calendar.component(.year, from: $0.date) == currentYear
            }
            .reduce(0) { $0 + $1.amount }
        
        // Update local storage
        saveTransactionsLocally()
        
        // Update in Supabase
        Task {
            _ = await transactionService.updateTransaction(
                id: id,
                amount: amount,
                description: description.isEmpty ? nil : description
            )
        }
    }
    
    // MARK: - Local Storage
    private func saveTransactionsLocally() {
        guard let userId = userId else { return }
        
        // Save transaction display items to UserDefaults
        let txData = transactions.map { tx in
            ["id": tx.id.uuidString,
             "title": tx.title,
             "amount": tx.amount,
             "icon": tx.categoryIcon,
             "color": "#808080",
             "dateString": tx.dateString,
             "date": tx.date.timeIntervalSince1970] as [String: Any]
        }
        
        UserDefaults.standard.set(txData, forKey: "transactions_\(userId)")
    }
    
    private func loadTransactionsLocally() {
        guard let userId = userId else { return }
        
        if let txData = UserDefaults.standard.array(forKey: "transactions_\(userId)") as? [[String: Any]] {
            self.transactions = txData.compactMap { dict in
                guard let idStr = dict["id"] as? String,
                      let id = UUID(uuidString: idStr),
                      let title = dict["title"] as? String,
                      let amount = dict["amount"] as? Double,
                      let icon = dict["icon"] as? String,
                      let dateString = dict["dateString"] as? String,
                      let dateInterval = dict["date"] as? TimeInterval else {
                    return nil
                }
                return TransactionDisplayItem(
                    id: id,
                    title: title,
                    amount: amount,
                    categoryIcon: icon,
                    categoryColor: .gray,
                    dateString: dateString,
                    date: Date(timeIntervalSince1970: dateInterval)
                )
            }
            
            // Recalculate total spent this month
            let calendar = Calendar.current
            let now = Date()
            let currentMonth = calendar.component(.month, from: now)
            let currentYear = calendar.component(.year, from: now)
            
            self.totalSpent = transactions
                .filter {
                    calendar.component(.month, from: $0.date) == currentMonth &&
                    calendar.component(.year, from: $0.date) == currentYear
                }
                .reduce(0) { $0 + $1.amount }
        }
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
