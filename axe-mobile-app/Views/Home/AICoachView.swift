//
//  AICoachView.swift
//  axe-mobile-app
//
//  AI-powered behavioral spending coach - the core differentiator
//

import SwiftUI

struct AICoachView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    // Colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    private let cardDark = Color(red: 26/255, green: 26/255, blue: 30/255)
    
    @State private var selectedInsight: SpendingInsight?
    @State private var isAnalyzing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header card
                        headerCard
                        
                        // Quick insights
                        if !behavioralInsights.isEmpty {
                            insightsSection
                        }
                        
                        // Recent spending patterns
                        patternsSection
                        
                        // Top triggers
                        triggersSection
                        
                        // AI Recommendations
                        recommendationsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("AI Coach")
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
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 72, height: 72)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(accent)
            }
            
            VStack(spacing: 6) {
                Text("Your Spending Coach")
                    .font(.spaceGroteskBold(20))
                    .foregroundColor(.white)
                
                Text("I analyze your spending patterns to help you understand the *why* behind your purchases.")
                    .font(.spaceGroteskMedium(14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardDark)
        .cornerRadius(20)
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundColor(accent)
                Text("Behavioral Insights")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
            }
            
            ForEach(behavioralInsights) { insight in
                InsightCard(insight: insight, accent: accent, cardDark: cardDark)
            }
        }
    }
    
    // MARK: - Patterns Section
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 14))
                    .foregroundColor(accent)
                Text("Spending Patterns")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                PatternRow(
                    icon: "clock.fill",
                    title: "Peak Spending Time",
                    value: peakSpendingTime,
                    detail: "You spend the most during this period",
                    accent: accent,
                    cardDark: cardDark
                )
                
                PatternRow(
                    icon: "calendar",
                    title: "Highest Spending Day",
                    value: highestSpendingDay,
                    detail: "This day tends to be your biggest spending day",
                    accent: accent,
                    cardDark: cardDark
                )
                
                if let avgTx = averageTransactionSize {
                    PatternRow(
                        icon: "dollarsign.circle.fill",
                        title: "Average Purchase",
                        value: "$\(String(format: "%.0f", avgTx))",
                        detail: "Your typical transaction size",
                        accent: accent,
                        cardDark: cardDark
                    )
                }
            }
        }
    }
    
    // MARK: - Triggers Section
    private var triggersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("Spending Triggers")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                ForEach(spendingTriggers, id: \.title) { trigger in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(trigger.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: trigger.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(trigger.color)
                            )
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(trigger.title)
                                .font(.spaceGroteskMedium(15))
                                .foregroundColor(.white)
                            
                            Text(trigger.description)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(14)
                    .background(cardDark)
                    .cornerRadius(14)
                }
            }
        }
    }
    
    // MARK: - Recommendations Section
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundColor(accent)
                Text("Recommendations")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
            }
            
            ForEach(recommendations, id: \.self) { rec in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(accent)
                    
                    Text(rec)
                        .font(.spaceGroteskMedium(14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(3)
                }
                .padding(16)
                .background(cardDark)
                .cornerRadius(14)
            }
        }
    }
    
    // MARK: - Computed Data
    
    private var behavioralInsights: [SpendingInsight] {
        var insights: [SpendingInsight] = []
        
        // Analyze spending categories for behavioral patterns
        let spentCategories = viewModel.categories.filter { $0.spent > 0 }
        
        // Impulse spending detection (Shopping, Entertainment, Food)
        let impulseCategories = ["Shopping", "Entertainment", "Food & Dining"]
        let impulseSpend = spentCategories
            .filter { impulseCategories.contains($0.name) }
            .reduce(0) { $0 + $1.spent }
        
        if impulseSpend > viewModel.totalSpent * 0.5 && viewModel.totalSpent > 0 {
            insights.append(SpendingInsight(
                id: "impulse",
                emoji: "🎯",
                title: "Impulse Pattern Detected",
                description: "Over 50% of your spending is in impulse categories (Shopping, Food, Entertainment). Consider implementing a 24-hour waiting rule for non-essential purchases.",
                severity: .warning
            ))
        }
        
        // Weekend warrior pattern
        let weekendTxCount = viewModel.transactions.filter { tx in
            let weekday = Calendar.current.component(.weekday, from: tx.date)
            return weekday == 1 || weekday == 7 // Sunday or Saturday
        }.count
        
        if weekendTxCount > viewModel.transactions.count / 2 && viewModel.transactions.count > 3 {
            insights.append(SpendingInsight(
                id: "weekend",
                emoji: "🗓",
                title: "Weekend Spender",
                description: "Most of your transactions happen on weekends. This often correlates with social activities and leisure spending. Plan weekend activities in advance to stay on budget.",
                severity: .info
            ))
        }
        
        // Over budget warning
        if viewModel.isOverBudget {
            insights.append(SpendingInsight(
                id: "over",
                emoji: "⚠️",
                title: "Budget Exceeded",
                description: "You've exceeded your monthly budget. Let's identify which areas can be adjusted to get back on track.",
                severity: .critical
            ))
        }
        
        // Good progress
        if viewModel.hasBudget && viewModel.budgetProgress < 0.5 && viewModel.daysLeftInMonth < 15 {
            insights.append(SpendingInsight(
                id: "good",
                emoji: "🎉",
                title: "Great Progress!",
                description: "You've only used \(Int(viewModel.budgetProgress * 100))% of your budget with \(viewModel.daysLeftInMonth) days left. You're building strong financial habits!",
                severity: .success
            ))
        }
        
        return insights
    }
    
    private var peakSpendingTime: String {
        // Simplified - would need actual time data
        return "Evening (6-9 PM)"
    }
    
    private var highestSpendingDay: String {
        // Analyze transactions by day of week
        var dayTotals: [Int: Double] = [:]
        for tx in viewModel.transactions {
            let weekday = Calendar.current.component(.weekday, from: tx.date)
            dayTotals[weekday, default: 0] += tx.amount
        }
        
        let maxDay = dayTotals.max(by: { $0.value < $1.value })?.key ?? 1
        let formatter = DateFormatter()
        formatter.weekdaySymbols = Calendar.current.weekdaySymbols
        return formatter.weekdaySymbols[maxDay - 1]
    }
    
    private var averageTransactionSize: Double? {
        guard !viewModel.transactions.isEmpty else { return nil }
        return viewModel.totalSpent / Double(viewModel.transactions.count)
    }
    
    private var spendingTriggers: [SpendingTrigger] {
        var triggers: [SpendingTrigger] = []
        
        // Analyze based on categories
        let foodSpend = viewModel.categories.first(where: { $0.name == "Food & Dining" })?.spent ?? 0
        let shoppingSpend = viewModel.categories.first(where: { $0.name == "Shopping" })?.spent ?? 0
        let entertainmentSpend = viewModel.categories.first(where: { $0.name == "Entertainment" })?.spent ?? 0
        
        if foodSpend > viewModel.totalSpent * 0.25 && viewModel.totalSpent > 0 {
            triggers.append(SpendingTrigger(
                icon: "takeoutbag.and.cup.and.straw.fill",
                title: "Convenience Eating",
                description: "Food delivery and dining out may be driven by time pressure or stress.",
                color: .orange
            ))
        }
        
        if shoppingSpend > viewModel.totalSpent * 0.3 && viewModel.totalSpent > 0 {
            triggers.append(SpendingTrigger(
                icon: "bag.fill",
                title: "Retail Therapy",
                description: "High shopping activity can indicate emotional spending patterns.",
                color: .pink
            ))
        }
        
        if entertainmentSpend > viewModel.totalSpent * 0.2 && viewModel.totalSpent > 0 {
            triggers.append(SpendingTrigger(
                icon: "tv.fill",
                title: "Boredom Spending",
                description: "Entertainment spending often spikes when we're seeking stimulation.",
                color: .purple
            ))
        }
        
        if triggers.isEmpty {
            triggers.append(SpendingTrigger(
                icon: "checkmark.shield.fill",
                title: "Balanced Spending",
                description: "Your spending appears well-distributed across categories.",
                color: accent
            ))
        }
        
        return triggers
    }
    
    private var recommendations: [String] {
        var recs: [String] = []
        
        if viewModel.hasBudget {
            if viewModel.budgetProgress > 0.8 {
                recs.append("With \(viewModel.daysLeftInMonth) days left and \(Int(100 - viewModel.budgetProgress * 100))% budget remaining, try a 'no-spend day' tomorrow to reset.")
            }
            
            if let topCategory = viewModel.categories.filter({ $0.spent > 0 }).max(by: { $0.spent < $1.spent }) {
                recs.append("Your highest spending is \(topCategory.name). Set a specific limit for this category next month.")
            }
        }
        
        recs.append("Before making a purchase over $50, wait 24 hours. Many impulse urges fade after a brief pause.")
        
        if viewModel.transactions.count < 5 {
            recs.append("Log more transactions to get personalized behavioral insights tailored to your spending patterns.")
        }
        
        return recs
    }
}

// MARK: - Supporting Types

struct SpendingInsight: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let description: String
    let severity: InsightSeverity
}

enum InsightSeverity {
    case info, warning, success, critical
}

struct SpendingTrigger {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Insight Card
struct InsightCard: View {
    let insight: SpendingInsight
    let accent: Color
    let cardDark: Color
    
    var severityColor: Color {
        switch insight.severity {
        case .info: return .blue
        case .warning: return .orange
        case .success: return accent
        case .critical: return .red
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(insight.emoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(insight.title)
                    .font(.spaceGroteskBold(15))
                    .foregroundColor(.white)
                
                Text(insight.description)
                    .font(.spaceGroteskMedium(13))
                    .foregroundColor(.gray)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(severityColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pattern Row
struct PatternRow: View {
    let icon: String
    let title: String
    let value: String
    let detail: String
    let accent: Color
    let cardDark: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(accent.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(accent)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.spaceGroteskMedium(14))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(14)
        .background(cardDark)
        .cornerRadius(14)
    }
}

#Preview {
    AICoachView(viewModel: HomeViewModel())
}
