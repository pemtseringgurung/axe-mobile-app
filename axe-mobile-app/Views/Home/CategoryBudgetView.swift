//
//  CategoryBudgetView.swift
//  axe-mobile-app
//
//  Category budget allocation sheet with add/remove custom categories and reordering
//

import SwiftUI

struct CategoryBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    // Local state for editing
    @State private var categoryBudgets: [UUID: String] = [:]
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "tag.fill"
    @State private var categoryToDelete: CategoryBudgetItem?
    @State private var showDeleteConfirm = false
    @State private var isReorderMode = false
    
    // Colors - consistent green theme
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    private let cardDark = Color(red: 26/255, green: 26/255, blue: 30/255)
    
    // Available icons for custom categories
    private let availableIcons = [
        "tag.fill", "star.fill", "gift.fill", "house.fill", "briefcase.fill",
        "graduationcap.fill", "music.note", "pawprint.fill", "leaf.fill", "drop.fill"
    ]
    
    var totalAllocated: Double {
        categoryBudgets.values.compactMap { Double($0) }.reduce(0, +)
    }
    
    var allocationProgress: Double {
        guard viewModel.totalBudget > 0 else { return 0 }
        return min(totalAllocated / viewModel.totalBudget, 1.0)
    }
    
    var isOverAllocated: Bool {
        totalAllocated > viewModel.totalBudget
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Allocation Summary Card
                    VStack(spacing: 16) {
                        // Progress header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ALLOCATED")
                                    .font(.system(size: 10, weight: .heavy))
                                    .foregroundColor(.white.opacity(0.4))
                                    .tracking(2)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("$\(String(format: "%.0f", totalAllocated))")
                                        .font(.spaceGroteskBold(28))
                                        .foregroundColor(isOverAllocated ? .red : .white)
                                    
                                    Text("/ $\(String(format: "%.0f", viewModel.totalBudget))")
                                        .font(.spaceGroteskMedium(16))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                            
                            // Percentage badge
                            Text("\(Int(allocationProgress * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(isOverAllocated ? .red : accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isOverAllocated ? Color.red.opacity(0.2) : accent.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isOverAllocated ? Color.red : accent)
                                    .frame(width: geo.size.width * min(allocationProgress, 1.0), height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        if isOverAllocated {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 12))
                                Text("Over budget by $\(String(format: "%.0f", totalAllocated - viewModel.totalBudget))")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding(20)
                    .background(cardDark)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Category List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.categories.enumerated()), id: \.element.id) { index, category in
                                CategoryBudgetRow(
                                    category: category,
                                    budgetText: binding(for: category.id),
                                    accent: accent,
                                    cardDark: cardDark,
                                    isReorderMode: isReorderMode,
                                    onDelete: category.isDefault ? nil : {
                                        categoryToDelete = category
                                        showDeleteConfirm = true
                                    },
                                    onMoveUp: index > 0 ? {
                                        viewModel.categories.swapAt(index, index - 1)
                                    } : nil,
                                    onMoveDown: index < viewModel.categories.count - 1 ? {
                                        viewModel.categories.swapAt(index, index + 1)
                                    } : nil
                                )
                            }
                            
                            // Add Category Button
                            Button(action: { showAddCategory = true }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .stroke(accent, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(accent)
                                        )
                                    
                                    Text("Add Custom Category")
                                        .font(.spaceGroteskMedium(15))
                                        .foregroundColor(accent)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(cardDark.opacity(0.5))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(accent.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                    
                    Spacer()
                    
                    // Save Button
                    Button(action: saveChanges) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save Allocations")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isOverAllocated ? Color.gray : accent)
                        .cornerRadius(14)
                    }
                    .disabled(isOverAllocated)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Allocate Budget")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isReorderMode.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: isReorderMode ? "checkmark" : "arrow.up.arrow.down")
                            Text(isReorderMode ? "Done" : "Reorder")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(accent)
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                addCategorySheet
            }
            .alert("Delete Category?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        viewModel.deleteCategory(categoryId: category.id)
                        categoryBudgets.removeValue(forKey: category.id)
                    }
                }
            } message: {
                Text("This will remove the category and its budget allocation.")
            }
        }
        .onAppear {
            // Initialize local state from viewModel
            for category in viewModel.categories {
                categoryBudgets[category.id] = category.budget > 0 ? String(format: "%.0f", category.budget) : ""
            }
        }
    }
    
    // MARK: - Add Category Sheet
    private var addCategorySheet: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Icon selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ICON")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    Button(action: { newCategoryIcon = icon }) {
                                        Circle()
                                            .stroke(newCategoryIcon == icon ? accent : Color.white.opacity(0.2), lineWidth: 1.5)
                                            .frame(width: 50, height: 50)
                                            .overlay(
                                                Image(systemName: icon.replacingOccurrences(of: ".fill", with: ""))
                                                    .font(.system(size: 18))
                                                    .foregroundColor(newCategoryIcon == icon ? accent : .white.opacity(0.6))
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    // Name input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("NAME")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.gray)
                            .tracking(2)
                        
                        TextField("e.g. Subscriptions", text: $newCategoryName)
                            .font(.spaceGroteskMedium(16))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(cardDark)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    // Add button
                    Button(action: addCategory) {
                        Text("Add Category")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(newCategoryName.isEmpty ? Color.gray : accent)
                            .cornerRadius(14)
                    }
                    .disabled(newCategoryName.isEmpty)
                }
                .padding(24)
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(bgColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showAddCategory = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }
    
    private func binding(for id: UUID) -> Binding<String> {
        Binding(
            get: { categoryBudgets[id] ?? "" },
            set: { categoryBudgets[id] = $0 }
        )
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        viewModel.addCategory(name: newCategoryName, icon: newCategoryIcon)
        newCategoryName = ""
        newCategoryIcon = "tag.fill"
        showAddCategory = false
    }
    
    private func saveChanges() {
        for (categoryId, budgetStr) in categoryBudgets {
            let amount = Double(budgetStr) ?? 0
            viewModel.setCategoryBudget(categoryId: categoryId, amount: amount)
        }
        dismiss()
    }
}

// MARK: - Category Budget Row
struct CategoryBudgetRow: View {
    let category: CategoryBudgetItem
    @Binding var budgetText: String
    let accent: Color
    let cardDark: Color
    var isReorderMode: Bool = false
    var onDelete: (() -> Void)?
    var onMoveUp: (() -> Void)?
    var onMoveDown: (() -> Void)?
    
    var budgetValue: Double {
        Double(budgetText) ?? 0
    }
    
    var spentProgress: Double {
        guard budgetValue > 0 else { return 0 }
        return min(category.spent / budgetValue, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                // Reorder buttons (when in reorder mode)
                if isReorderMode {
                    VStack(spacing: 4) {
                        Button(action: { onMoveUp?() }) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(onMoveUp != nil ? accent : .gray.opacity(0.3))
                        }
                        .disabled(onMoveUp == nil)
                        
                        Button(action: { onMoveDown?() }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(onMoveDown != nil ? accent : .gray.opacity(0.3))
                        }
                        .disabled(onMoveDown == nil)
                    }
                    .frame(width: 30)
                }
                
                // Category icon - always green
                Circle()
                    .stroke(accent, lineWidth: 1.5)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: category.icon.replacingOccurrences(of: ".fill", with: ""))
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(accent)
                    )
                
                // Name and spent
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.spaceGroteskMedium(15))
                        .foregroundColor(.white)
                    
                    Text("$\(String(format: "%.0f", category.spent)) spent")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Budget input (hidden in reorder mode)
                if !isReorderMode {
                    HStack(spacing: 2) {
                        Text("$")
                            .font(.spaceGroteskMedium(16))
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("0", text: $budgetText)
                            .font(.spaceGroteskBold(20))
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    // Delete button (only for custom categories)
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .padding(.leading, 8)
                    }
                }
            }
            
            // Spent progress bar (only show if budget set and not in reorder mode)
            if budgetValue > 0 && !isReorderMode {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accent) // Always green
                            .frame(width: geo.size.width * spentProgress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(cardDark)
        .cornerRadius(16)
        .animation(.easeInOut(duration: 0.2), value: isReorderMode)
    }
}

#Preview {
    CategoryBudgetView(viewModel: HomeViewModel())
}
