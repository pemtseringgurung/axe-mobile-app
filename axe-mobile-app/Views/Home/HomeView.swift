//
//  HomeView.swift
//  axe-mobile-app
//
//  Modern polished dark theme dashboard
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var showAddTransaction = false
    @State private var showBudgetSetup = false
    @State private var showProfile = false
    @State private var showTransactionDetail = false
    @State private var showAllTransactions = false
    @State private var showCategoryBudget = false
    @State private var showAnalytics = false
    @State private var showAICoach = false
    @State private var selectedTransaction: TransactionDisplayItem?
    @State private var selectedTab = 0
    
    // Colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let cardColor = Color(red: 185/255, green: 255/255, blue: 100/255)
    private let cardDark = Color(red: 26/255, green: 26/255, blue: 30/255)
    
    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Main Budget Card
                        mainCard
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        // Categories
                        if viewModel.hasBudget {
                            categoriesSection
                                .padding(.horizontal, 20)
                        }
                        
                        // Recent Transactions
                        transactionsSection
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 100) // Space for floating tab bar
                }
            }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 0) {
                // Gradient fade to hide content behind tab bar
                LinearGradient(
                    colors: [bgColor.opacity(0), bgColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 40)
                
                // Solid background area for tab bar
                bgColor
                    .frame(height: 80)
            }
            .allowsHitTesting(false) // Let taps pass through to tab bar
        }
        .overlay(alignment: .bottom) {
            floatingTabBar
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showBudgetSetup) {
            SetupBudgetView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction, viewModel: viewModel)
        }
        .sheet(isPresented: $showAllTransactions) {
            AllTransactionsView(viewModel: viewModel, selectedTransaction: $selectedTransaction)
        }
        .sheet(isPresented: $showCategoryBudget) {
            CategoryBudgetView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showAICoach) {
            AICoachView(viewModel: viewModel)
        }
        .onAppear {
            if let userId = authService.userId {
                viewModel.loadData(userId: userId)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack(spacing: 14) {
            // Logo - modern creative
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(cardColor)
                
                Text("axe")
                    .font(.spaceGroteskBold(26))
                    .tracking(-0.5)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Notification
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 42, height: 42)
                    .background(cardDark)
                    .clipShape(Circle())
            }
            
            // Profile
            Button(action: { showProfile = true }) {
                Circle()
                    .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text(String(viewModel.firstName(from: authService.userEmail).prefix(1)).uppercased())
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
            }
        }
    }
    
    // MARK: - Main Card
    private var mainCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                // Top row
                HStack {
                    HStack(spacing: 6) {
                        Text("Monthly Budget")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.black.opacity(0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.12))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    if viewModel.hasBudget {
                        HStack(spacing: 6) {
                            Button(action: {}) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 13))
                                    .foregroundColor(.black.opacity(0.7))
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: { showBudgetSetup = true }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 13))
                                    .foregroundColor(.black.opacity(0.7))
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.5))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                if viewModel.hasBudget {
                    // Balance display - modern fintech style
                    VStack(alignment: .leading, spacing: 8) {
                        Text("REMAINING")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.black.opacity(0.4))
                            .tracking(2)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("$")
                                    .font(.spaceGroteskMedium(28))
                                    .foregroundColor(.black)
                                
                                Text("\(String(format: "%.2f", viewModel.remaining))")
                                    .font(.spaceGroteskBold(44))
                                    .foregroundColor(.black)
                            }
                            
                            Text("\(Int(100 - viewModel.budgetProgress * 100))%")
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(.black.opacity(0.35))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.08))
                                .cornerRadius(6)
                        }
                    }
                    
                    // Clean bottom corner - no cluttered action buttons
                    HStack {
                        Spacer()
                        
                        // Just a subtle grid button for category overview
                        Button(action: { showCategoryBudget = true }) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(12)
                        }
                    }
                    
                } else {
                    // Setup prompt
                    VStack(spacing: 16) {
                        Text("Set your monthly budget")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text("Track spending and reach your goals")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.black.opacity(0.55))
                        
                        Button(action: { showBudgetSetup = true }) {
                            Text("Get Started")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(cardColor)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 13)
                                .background(Color.black)
                                .cornerRadius(25)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 16)
                }
            }
            .padding(22)
        }
        .background(cardColor)
        .cornerRadius(26)
    }
    
    // MARK: - Categories
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showCategoryBudget = true }) {
                    Text("Manage")
                        .font(.spaceGroteskMedium(13))
                        .foregroundColor(.gray)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.categories) { category in
                        CategoryBubble(category: category, accent: cardColor)
                    }
                }
                .padding(.vertical, 2) // Prevents clipping of circle rings
            }
        }
    }
    
    // MARK: - Transactions
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.spaceGroteskBold(17))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showAllTransactions = true }) {
                    Text("See all")
                        .font(.spaceGroteskMedium(13))
                        .foregroundColor(.gray)
                }
            }
            
            if viewModel.transactions.isEmpty {
                VStack(spacing: 16) {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "doc.text")
                                .font(.system(size: 22, weight: .light))
                                .foregroundColor(.white.opacity(0.4))
                        )
                    
                    Text("No transactions yet")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Button(action: { showAddTransaction = true }) {
                        Text("Add your first")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(cardColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.transactions.prefix(2)) { tx in
                        TransactionRow(transaction: tx, accent: cardColor)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTransaction = tx
                            }
                        
                        if tx.id != viewModel.transactions.prefix(2).last?.id {
                            Rectangle()
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 1)
                                .padding(.leading, 60)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Bar
    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            // Home
            TabIcon(icon: "house", isSelected: selectedTab == 0) { selectedTab = 0 }
            
            // AI Coach - the core feature!
            Button(action: { showAICoach = true }) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
            
            // Center FAB - Add Transaction
            Button(action: { showAddTransaction = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 50, height: 50)
                    .background(cardColor)
                    .clipShape(Circle())
            }
            .offset(y: -8)
            
            // Analytics
            Button(action: { showAnalytics = true }) {
                Image(systemName: "chart.pie")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
            
            // Profile
            Button(action: { showProfile = true }) {
                Image(systemName: "person")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(cardDark)
        .cornerRadius(28)
    }
}

// MARK: - Action Circle
struct ActionCircle: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 48, height: 48)
                .background(Color.white)
                .clipShape(Circle())
        }
    }
}

// MARK: - Category Bubble
struct CategoryBubble: View {
    let category: CategoryBudgetItem
    let accent: Color
    
    var progress: Double {
        guard category.budget > 0 else { return 0 }
        return min(category.spent / category.budget, 1.0)
    }
    
    func shortName(_ name: String) -> String {
        switch name {
        case "Food & Dining": return "Food"
        case "Transportation": return "Transport"
        case "Entertainment": return "Fun"
        default: return name.components(separatedBy: " ").first ?? name
        }
    }
    
    // Convert filled icons to outline
    func outlineIcon(_ icon: String) -> String {
        icon.replacingOccurrences(of: ".fill", with: "")
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 56, height: 56)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                
                // Outline icon
                Image(systemName: outlineIcon(category.icon))
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(progress > 0 ? accent : .white.opacity(0.6))
            }
            
            Text(shortName(category.name))
                .font(.spaceGroteskMedium(11))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 72)
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: TransactionDisplayItem
    let accent: Color
    
    // Convert filled icons to outline
    func outlineIcon(_ icon: String) -> String {
        icon.replacingOccurrences(of: ".fill", with: "")
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Outline circle with icon
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: outlineIcon(transaction.categoryIcon))
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.spaceGroteskMedium(15))
                    .foregroundColor(.white)
                
                Text(transaction.dateString)
                    .font(.spaceGrotesk(12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("-$\(String(format: "%.2f", transaction.amount))")
                .font(.spaceGroteskBold(15))
                .foregroundColor(.white)
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Tab Icon
struct TabIcon: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(isSelected ? .white : .gray.opacity(0.5))
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthService.shared)
}
