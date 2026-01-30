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
    
    // Custom decoder to handle Supabase "YYYY-MM-DD" date format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        categoryId = try container.decodeIfPresent(UUID.self, forKey: .categoryId)
        amount = try container.decode(Double.self, forKey: .amount)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        
        // Handle date - try as Date first, then as String
        if let dateValue = try? container.decode(Date.self, forKey: .date) {
            date = dateValue
        } else if let dateString = try? container.decode(String.self, forKey: .date) {
            // Parse "YYYY-MM-DD" format
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let parsedDate = formatter.date(from: dateString) {
                date = parsedDate
            } else {
                throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Cannot parse date: \(dateString)")
            }
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date is missing")
        }
    }
    
    // Standard initializer for creating transactions in code
    init(id: UUID, userId: UUID, categoryId: UUID?, amount: Double, description: String?, date: Date, createdAt: Date?) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.amount = amount
        self.description = description
        self.date = date
        self.createdAt = createdAt
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
        Category(id: UUID(), name: "Food & Dining", icon: "fork.knife", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Transportation", icon: "car.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Shopping", icon: "bag.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Entertainment", icon: "tv.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Bills & Utilities", icon: "bolt.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Health & Fitness", icon: "heart.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Travel", icon: "airplane", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Subscriptions", icon: "repeat.circle.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Personal Care", icon: "sparkles", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Education", icon: "book.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Savings", icon: "banknote.fill", color: "#B9FF64", isDefault: true),
        Category(id: UUID(), name: "Other", icon: "ellipsis.circle.fill", color: "#B9FF64", isDefault: true)
    ]
}
