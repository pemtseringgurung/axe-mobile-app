//
//  AnalyticsView.swift
//  axe-mobile-app
//
//  Spending analytics with charts and insights
//

import SwiftUI

struct AnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    // State for month/year selection
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    @State private var showMonthPicker = false
    
    // Colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    private let cardDark = Color(red: 26/255, green: 26/255, blue: 30/255)
    
    // Chart colors
    private let chartColors: [Color] = [
        Color(red: 185/255, green: 255/255, blue: 100/255), // Lime
        Color(red: 100/255, green: 200/255, blue: 255/255), // Light blue
        Color(red: 255/255, green: 180/255, blue: 100/255), // Orange
        Color(red: 200/255, green: 150/255, blue: 255/255), // Purple
        Color(red: 255/255, green: 130/255, blue: 150/255), // Pink
        Color(red: 130/255, green: 220/255, blue: 180/255), // Teal
    ]
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        let calendar = Calendar.current
        let now = Date()
        _selectedMonth = State(initialValue: calendar.component(.month, from: now))
        _selectedYear = State(initialValue: calendar.component(.year, from: now))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Month/Year Picker
                        monthYearPicker
                        
                        // Monthly summary card
                        monthlySummaryCard
                        
                        // Spending by category (donut chart)
                        categoryBreakdownCard
                        
                        // Daily spending bar chart
                        dailySpendingCard
                        
                        // Top spending categories
                        topCategoriesCard
                        
                        // Insights
                        insightsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Analytics")
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
            .sheet(isPresented: $showMonthPicker) {
                monthPickerSheet
            }
        }
    }
    
    // MARK: - Month/Year Picker
    private var monthYearPicker: some View {
        HStack {
            // Previous month
            Button(action: goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(cardDark)
                    .cornerRadius(10)
            }
            
            Spacer()
            
            // Month/Year display (tappable)
            Button(action: { showMonthPicker = true }) {
                HStack(spacing: 8) {
                    Text(selectedMonthYear)
                        .font(.spaceGroteskBold(18))
                        .foregroundColor(.white)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(cardDark)
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Next month (disabled if current month)
            Button(action: goToNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(canGoToNextMonth ? .white.opacity(0.6) : .white.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .background(cardDark)
                    .cornerRadius(10)
            }
            .disabled(!canGoToNextMonth)
        }
    }
    
    // MARK: - Month Picker Sheet
    private var monthPickerSheet: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Year selector
                    HStack {
                        Button(action: { selectedYear -= 1 }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(String(selectedYear))
                            .font(.spaceGroteskBold(24))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { 
                            if selectedYear < Calendar.current.component(.year, from: Date()) {
                                selectedYear += 1 
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(selectedYear < Calendar.current.component(.year, from: Date()) ? .white : .gray)
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Month grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(1...12, id: \.self) { month in
                            let isSelected = month == selectedMonth && !isMonthDisabled(month)
                            let isDisabled = isMonthDisabled(month)
                            
                            Button(action: { 
                                if !isDisabled {
                                    selectedMonth = month
                                    showMonthPicker = false
                                }
                            }) {
                                Text(monthName(month))
                                    .font(.spaceGroteskMedium(15))
                                    .foregroundColor(isDisabled ? .gray.opacity(0.3) : (isSelected ? .black : .white))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(isSelected ? accent : cardDark)
                                    .cornerRadius(12)
                            }
                            .disabled(isDisabled)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(bgColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showMonthPicker = false }
                        .font(.spaceGroteskMedium(16))
                        .foregroundColor(accent)
                }
            }
        }
    }
    
    // MARK: - Monthly Summary
    private var monthlySummaryCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 24) {
                // Spent
                VStack(alignment: .leading, spacing: 4) {
                    Text("SPENT")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.gray)
                        .tracking(2)
                    Text("$\(String(format: "%.0f", totalSpentForPeriod))")
                        .font(.spaceGroteskBold(28))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Daily Average
                VStack(alignment: .trailing, spacing: 4) {
                    Text("DAILY AVG")
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundColor(.gray)
                        .tracking(2)
                    Text("$\(String(format: "%.0f", dailyAverageForPeriod))")
                        .font(.spaceGroteskBold(28))
                        .foregroundColor(accent)
                }
            }
            
            // Transaction count
            HStack {
                Text("\(transactionsForPeriod.count) transactions")
                    .font(.spaceGroteskMedium(13))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(20)
        .background(cardDark)
        .cornerRadius(20)
    }
    
    // MARK: - Category Breakdown (Donut Chart)
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Spending by Category")
                .font(.spaceGroteskBold(17))
                .foregroundColor(.white)
            
            if categorySpendingData.isEmpty {
                emptyChartPlaceholder
            } else {
                HStack(spacing: 24) {
                    // Donut Chart
                    DonutChart(data: categorySpendingData, colors: chartColors, totalSpent: totalSpentForPeriod)
                        .frame(width: 140, height: 140)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(categorySpendingData.prefix(5).enumerated()), id: \.element.name) { index, item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(chartColors[index % chartColors.count])
                                    .frame(width: 8, height: 8)
                                
                                Text(item.name)
                                    .font(.spaceGroteskMedium(12))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text("\(Int(item.percentage))%")
                                    .font(.spaceGroteskBold(12))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(cardDark)
        .cornerRadius(20)
    }
    
    // MARK: - Daily Spending Bar Chart with Y-Axis
    private var dailySpendingCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily Spending")
                .font(.spaceGroteskBold(17))
                .foregroundColor(.white)
            
            if weeklySpendingData.allSatisfy({ $0.amount == 0 }) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No transactions this period")
                        .font(.spaceGroteskMedium(13))
                        .foregroundColor(.gray)
                }
                .frame(height: 150)
                .frame(maxWidth: .infinity)
            } else {
                HStack(alignment: .bottom, spacing: 0) {
                    // Y-Axis labels
                    VStack(alignment: .trailing) {
                        Text("$\(formatAxisLabel(maxDailySpend))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("$\(formatAxisLabel(maxDailySpend / 2))")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("$0")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 40, height: 100)
                    .padding(.bottom, 24) // Space for day labels
                    
                    // Bars
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(weeklySpendingData, id: \.day) { item in
                            VStack(spacing: 6) {
                                // Amount label on top of bar (only if > 0)
                                if item.amount > 0 {
                                    Text("$\(Int(item.amount))")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(item.isToday ? accent : .gray)
                                }
                                
                                // Bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(item.isToday ? accent : accent.opacity(0.4))
                                    .frame(height: max(4, CGFloat(item.amount / maxDailySpend) * 100))
                                
                                // Day label
                                Text(item.day)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(item.isToday ? .white : .gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 150)
            }
        }
        .padding(20)
        .background(cardDark)
        .cornerRadius(20)
    }
    
    // MARK: - Top Categories
    private var topCategoriesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Spending")
                .font(.spaceGroteskBold(17))
                .foregroundColor(.white)
            
            if categorySpendingData.isEmpty {
                Text("No transactions yet")
                    .font(.spaceGroteskMedium(14))
                    .foregroundColor(.gray)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(categorySpendingData.prefix(3).enumerated()), id: \.element.name) { index, item in
                    HStack(spacing: 14) {
                        // Rank
                        Text("\(index + 1)")
                            .font(.spaceGroteskBold(16))
                            .foregroundColor(accent)
                            .frame(width: 24)
                        
                        // Icon
                        Circle()
                            .stroke(accent, lineWidth: 1.5)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: item.icon.replacingOccurrences(of: ".fill", with: ""))
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundColor(accent)
                            )
                        
                        // Name
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.spaceGroteskMedium(15))
                                .foregroundColor(.white)
                            
                            Text("\(item.transactionCount) transaction\(item.transactionCount == 1 ? "" : "s")")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Amount
                        Text("$\(String(format: "%.0f", item.amount))")
                            .font(.spaceGroteskBold(17))
                            .foregroundColor(.white)
                    }
                    
                    if index < 2 && categorySpendingData.count > index + 1 {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
            }
        }
        .padding(20)
        .background(cardDark)
        .cornerRadius(20)
    }
    
    // MARK: - Insights Card
    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(accent)
                Text("Insights")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
            }
            
            // Smart insights for selected period
            if smartInsights.isEmpty {
                Text("Add more transactions to get personalized insights.")
                    .font(.spaceGroteskMedium(14))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            } else {
                ForEach(smartInsights, id: \.self) { insight in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(accent.opacity(0.6))
                        
                        Text(insight)
                            .font(.spaceGroteskMedium(13))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(3)
                    }
                }
            }
        }
        .padding(20)
        .background(cardDark)
        .cornerRadius(20)
    }
    
    private var emptyChartPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.gray.opacity(0.4))
            Text("No spending data for this period")
                .font(.spaceGroteskMedium(14))
                .foregroundColor(.gray)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Functions
    
    private func goToPreviousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
    }
    
    private func goToNextMonth() {
        guard canGoToNextMonth else { return }
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
    }
    
    private var canGoToNextMonth: Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        if selectedYear < currentYear { return true }
        if selectedYear == currentYear && selectedMonth < currentMonth { return true }
        return false
    }
    
    private func isMonthDisabled(_ month: Int) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        if selectedYear < currentYear { return false }
        if selectedYear == currentYear { return month > currentMonth }
        return true
    }
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        var components = DateComponents()
        components.month = month
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return ""
    }
    
    private func formatAxisLabel(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.0fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }
    
    // MARK: - Computed Data for Selected Period
    
    private var selectedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return ""
    }
    
    private var transactionsForPeriod: [TransactionDisplayItem] {
        let calendar = Calendar.current
        return viewModel.transactions.filter { tx in
            let txMonth = calendar.component(.month, from: tx.date)
            let txYear = calendar.component(.year, from: tx.date)
            return txMonth == selectedMonth && txYear == selectedYear
        }
    }
    
    private var totalSpentForPeriod: Double {
        transactionsForPeriod.reduce(0) { $0 + $1.amount }
    }
    
    private var dailyAverageForPeriod: Double {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        // If current month, use days elapsed; otherwise use full month
        if selectedMonth == currentMonth && selectedYear == currentYear {
            let day = calendar.component(.day, from: now)
            guard day > 0 else { return 0 }
            return totalSpentForPeriod / Double(day)
        } else {
            // Past month - use total days in that month
            var components = DateComponents()
            components.month = selectedMonth
            components.year = selectedYear
            if let date = calendar.date(from: components),
               let range = calendar.range(of: .day, in: .month, for: date) {
                return totalSpentForPeriod / Double(range.count)
            }
        }
        return 0
    }
    
    private var categorySpendingData: [CategorySpendingItem] {
        // Calculate spending per category for selected period
        var categoryAmounts: [String: (amount: Double, icon: String, count: Int)] = [:]
        
        for tx in transactionsForPeriod {
            // Match transaction to category by icon
            if let cat = viewModel.categories.first(where: { $0.icon == tx.categoryIcon }) {
                let existing = categoryAmounts[cat.name] ?? (amount: 0, icon: cat.icon, count: 0)
                categoryAmounts[cat.name] = (amount: existing.amount + tx.amount, icon: cat.icon, count: existing.count + 1)
            }
        }
        
        let total = totalSpentForPeriod
        return categoryAmounts.map { name, data in
            CategorySpendingItem(
                name: name,
                icon: data.icon,
                amount: data.amount,
                percentage: total > 0 ? (data.amount / total) * 100 : 0,
                transactionCount: data.count
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    private var weeklySpendingData: [DailySpendingItem] {
        let calendar = Calendar.current
        
        // Get days in selected month
        var components = DateComponents()
        components.month = selectedMonth
        components.year = selectedYear
        components.day = 1
        
        guard let monthStart = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        
        // For current month, show last 7 days; for past months, show last 7 days of that month
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        let endDay: Int
        if selectedMonth == currentMonth && selectedYear == currentYear {
            endDay = calendar.component(.day, from: now)
        } else {
            endDay = range.count
        }
        
        let startDay = max(1, endDay - 6)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        var data: [DailySpendingItem] = []
        
        for day in startDay...endDay {
            var dayComponents = DateComponents()
            dayComponents.year = selectedYear
            dayComponents.month = selectedMonth
            dayComponents.day = day
            
            guard let date = calendar.date(from: dayComponents) else { continue }
            
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
            
            let dayTotal = transactionsForPeriod
                .filter { $0.date >= dayStart && $0.date < dayEnd }
                .reduce(0) { $0 + $1.amount }
            
            let isToday = calendar.isDateInToday(date)
            
            data.append(DailySpendingItem(
                day: dayFormatter.string(from: date),
                amount: dayTotal,
                isToday: isToday
            ))
        }
        
        return data
    }
    
    private var maxDailySpend: Double {
        max(weeklySpendingData.map { $0.amount }.max() ?? 1, 1)
    }
    
    private var smartInsights: [String] {
        var insights: [String] = []
        
        // Top category insight
        if let top = categorySpendingData.first {
            insights.append("\(top.name) is your biggest expense at $\(String(format: "%.0f", top.amount)).")
        }
        
        // Transaction count
        let txCount = transactionsForPeriod.count
        if txCount > 0 {
            let avgPerTx = totalSpentForPeriod / Double(txCount)
            insights.append("Average transaction: $\(String(format: "%.0f", avgPerTx))")
        }
        
        return insights
    }
}

// MARK: - Supporting Data Types
struct CategorySpendingItem {
    let name: String
    let icon: String
    let amount: Double
    let percentage: Double
    let transactionCount: Int
}

struct DailySpendingItem {
    let day: String
    let amount: Double
    let isToday: Bool
}

// MARK: - Donut Chart
struct DonutChart: View {
    let data: [CategorySpendingItem]
    let colors: [Color]
    let totalSpent: Double
    
    var body: some View {
        ZStack {
            // Segments
            ForEach(Array(segmentAngles.enumerated()), id: \.offset) { index, angles in
                DonutSegment(startAngle: angles.start, endAngle: angles.end)
                    .fill(colors[index % colors.count])
            }
            
            // Center hole
            Circle()
                .fill(Color(red: 26/255, green: 26/255, blue: 30/255))
                .frame(width: 80, height: 80)
            
            // Total in center
            VStack(spacing: 2) {
                Text("$\(String(format: "%.0f", totalSpent))")
                    .font(.spaceGroteskBold(16))
                    .foregroundColor(.white)
                Text("total")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var segmentAngles: [(start: Angle, end: Angle)] {
        var angles: [(start: Angle, end: Angle)] = []
        var currentAngle: Double = -90 // Start from top
        
        for item in data {
            let sweep = (item.percentage / 100) * 360
            angles.append((
                start: Angle(degrees: currentAngle),
                end: Angle(degrees: currentAngle + sweep)
            ))
            currentAngle += sweep
        }
        
        return angles
    }
}

struct DonutSegment: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.6
        
        path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    AnalyticsView(viewModel: HomeViewModel())
}
