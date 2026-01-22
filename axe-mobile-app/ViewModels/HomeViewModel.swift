//
//  HomeViewModel.swift
//  axe-mobile-app
//
//  ViewModel for home dashboard - manages budget data
//

import Foundation
import SwiftUI
import Combine

// MARK: - Data Models
struct CategoryBudgetItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    var budget: Double
    var spent: Double
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

struct SavedTransaction: Codable, Identifiable {
    let id: UUID
    let amount: Double
    let category: String
    let description: String
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
    private var rawTransactions: [SavedTransaction] = []
    
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
        
        // Load budget
        if let saved = UserDefaults.standard.value(forKey: "budget_\(userId)") as? Double {
            self.totalBudget = saved
        }
        
        // Load transactions
        loadTransactions()
        
        // Setup default categories if budget exists
        if hasBudget {
            setupCategories()
        }
    }
    
    private func loadTransactions() {
        guard let userId = userId else { return }
        
        if let data = UserDefaults.standard.data(forKey: "transactions_\(userId)"),
           let decoded = try? JSONDecoder().decode([SavedTransaction].self, from: data) {
            
            self.rawTransactions = decoded.sorted { $0.date > $1.date }
            
            self.transactions = rawTransactions.map { tx in
                TransactionDisplayItem(
                    id: tx.id,
                    title: tx.description.isEmpty ? tx.category : tx.description,
                    amount: tx.amount,
                    categoryIcon: iconFor(tx.category),
                    categoryColor: colorFor(tx.category),
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
    }
    
    private func setupCategories() {
        // Calculate spending per category
        var categorySpending: [String: Double] = [:]
        for tx in rawTransactions {
            categorySpending[tx.category, default: 0] += tx.amount
        }
        
        // Default category distribution
        let categoryData: [(String, String, Color, Double)] = [
            ("Food & Dining", "cup.and.saucer.fill", Color(red: 255/255, green: 107/255, blue: 107/255), 0.30),
            ("Transportation", "tram.fill", Color(red: 78/255, green: 205/255, blue: 196/255), 0.15),
            ("Shopping", "handbag.fill", Color(red: 69/255, green: 183/255, blue: 209/255), 0.20),
            ("Entertainment", "gamecontroller.fill", Color(red: 150/255, green: 206/255, blue: 180/255), 0.15),
            ("Bills", "creditcard.fill", Color(red: 255/255, green: 234/255, blue: 167/255), 0.10),
            ("Other", "square.grid.2x2.fill", Color.gray, 0.10)
        ]
        
        self.categories = categoryData.map { (name, icon, color, percent) in
            CategoryBudgetItem(
                name: name,
                icon: icon,
                color: color,
                budget: totalBudget * percent,
                spent: categorySpending[name] ?? 0
            )
        }
    }
    
    // MARK: - Actions
    func setBudget(amount: Double) {
        guard let userId = userId else { return }
        self.totalBudget = amount
        UserDefaults.standard.set(amount, forKey: "budget_\(userId)")
        setupCategories()
    }
    
    func addTransaction(amount: Double, category: String, description: String, date: Date) {
        guard let userId = userId else { return }
        
        let tx = SavedTransaction(
            id: UUID(),
            amount: amount,
            category: category,
            description: description,
            date: date
        )
        
        rawTransactions.insert(tx, at: 0)
        
        if let encoded = try? JSONEncoder().encode(rawTransactions) {
            UserDefaults.standard.set(encoded, forKey: "transactions_\(userId)")
        }
        
        loadTransactions()
        setupCategories()
    }
    
    // MARK: - Helpers
    private func iconFor(_ category: String) -> String {
        switch category {
        case "Food & Dining": return "cup.and.saucer.fill"
        case "Transportation": return "tram.fill"
        case "Shopping": return "handbag.fill"
        case "Entertainment": return "gamecontroller.fill"
        case "Bills": return "creditcard.fill"
        default: return "square.grid.2x2.fill"
        }
    }
    
    private func colorFor(_ category: String) -> Color {
        switch category {
        case "Food & Dining": return Color(red: 255/255, green: 107/255, blue: 107/255)
        case "Transportation": return Color(red: 78/255, green: 205/255, blue: 196/255)
        case "Shopping": return Color(red: 69/255, green: 183/255, blue: 209/255)
        case "Entertainment": return Color(red: 150/255, green: 206/255, blue: 180/255)
        case "Bills": return Color(red: 255/255, green: 234/255, blue: 167/255)
        default: return .gray
        }
    }
    
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
