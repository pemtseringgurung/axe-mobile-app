//
//  Models.swift
//  axe-mobile-app
//
//  Data models for the app
//

import Foundation

// MARK: - Category
struct Category: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let color: String
    let isDefault: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, color
        case isDefault = "is_default"
    }
}

// MARK: - Budget
struct Budget: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID?
    var amount: Double
    let month: Int
    let year: Int
    var rolloverEnabled: Bool
    var rolloverAmount: Double
    let createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case amount, month, year
        case rolloverEnabled = "rollover_enabled"
        case rolloverAmount = "rollover_amount"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Budget Input (for creating/updating)
struct BudgetInput: Codable {
    let userId: UUID
    let categoryId: UUID?
    let amount: Double
    let month: Int
    let year: Int
    let rolloverEnabled: Bool
    let rolloverAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case categoryId = "category_id"
        case amount, month, year
        case rolloverEnabled = "rollover_enabled"
        case rolloverAmount = "rollover_amount"
    }
}

// MARK: - Transaction
struct Transaction: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID?
    var amount: Double
    var description: String?
    var date: Date
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case categoryId = "category_id"
        case amount, description, date
        case createdAt = "created_at"
    }
}

// MARK: - Budget with Category (for display)
struct BudgetWithCategory: Identifiable {
    let budget: Budget
    let category: Category?
    var spent: Double = 0
    
    var id: UUID { budget.id }
    var remaining: Double { budget.amount + budget.rolloverAmount - spent }
    var progress: Double {
        let total = budget.amount + budget.rolloverAmount
        guard total > 0 else { return 0 }
        return min(spent / total, 1.0)
    }
}

// MARK: - Default Categories (fallback)
extension Category {
    static let defaults: [Category] = [
        Category(id: UUID(), name: "Food & Dining", icon: "cup.and.saucer.fill", color: "#FF6B6B", isDefault: true),
        Category(id: UUID(), name: "Transportation", icon: "tram.fill", color: "#4ECDC4", isDefault: true),
        Category(id: UUID(), name: "Shopping", icon: "handbag.fill", color: "#45B7D1", isDefault: true),
        Category(id: UUID(), name: "Entertainment", icon: "gamecontroller.fill", color: "#96CEB4", isDefault: true),
        Category(id: UUID(), name: "Bills & Utilities", icon: "creditcard.fill", color: "#FFEAA7", isDefault: true),
        Category(id: UUID(), name: "Health", icon: "heart.fill", color: "#DDA0DD", isDefault: true),
        Category(id: UUID(), name: "Other", icon: "square.grid.2x2.fill", color: "#636E72", isDefault: true)
    ]
}
