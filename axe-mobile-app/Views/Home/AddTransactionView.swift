//
//  AddTransactionView.swift
//  axe-mobile-app
//
//  Minimal modern transaction entry - uses categories from Supabase
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategoryId: UUID?
    @State private var date = Date()
    
    // Minimal colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    // Get categories from viewModel (loaded from Supabase)
    private var categories: [CategoryBudgetItem] {
        viewModel.categories
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 40) {
                            // Amount - minimal
                            VStack(spacing: 16) {
                                Text("AMOUNT")
                                    .font(.spaceGroteskMedium(11))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("$")
                                        .font(.spaceGroteskLight(36))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    TextField("0", text: $amount)
                                        .font(.spaceGroteskBold(56))
                                        .foregroundColor(.white)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: 200)
                                }
                            }
                            .padding(.top, 32)
                            
                            // Category - outline style, loaded from Supabase
                            VStack(alignment: .leading, spacing: 16) {
                                Text("CATEGORY")
                                    .font(.spaceGroteskMedium(11))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                    .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(categories) { category in
                                            let isSelected = selectedCategoryId == category.id
                                            
                                            VStack(spacing: 10) {
                                                ZStack {
                                                    Circle()
                                                        .stroke(isSelected ? accent : Color.white.opacity(0.2), lineWidth: 1.5)
                                                        .frame(width: 52, height: 52)
                                                    
                                                    Image(systemName: category.icon.replacingOccurrences(of: ".fill", with: ""))
                                                        .font(.system(size: 20, weight: .light))
                                                        .foregroundColor(isSelected ? accent : .white.opacity(0.6))
                                                }
                                                
                                                Text(shortName(for: category.name))
                                                    .font(.spaceGroteskMedium(11))
                                                    .foregroundColor(isSelected ? .white : .gray)
                                                    .lineLimit(1)
                                            }
                                            .frame(width: 60)
                                            .onTapGesture { 
                                                withAnimation(.easeOut(duration: 0.15)) {
                                                    selectedCategoryId = category.id
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 4)
                                }
                            }
                            
                            // Note - minimal underline style
                            VStack(alignment: .leading, spacing: 12) {
                                Text("NOTE")
                                    .font(.spaceGroteskMedium(11))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                TextField("What was this for?", text: $description)
                                    .font(.spaceGroteskMedium(16))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.white.opacity(0.1)),
                                        alignment: .bottom
                                    )
                            }
                            .padding(.horizontal, 24)
                            
                            // Date
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DATE")
                                    .font(.spaceGroteskMedium(11))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                    .accentColor(accent)
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Save Button
                    Button(action: saveTransaction) {
                        Text("Add Transaction")
                            .font(.spaceGroteskBold(16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? accent : Color.white.opacity(0.2))
                            .cornerRadius(14)
                    }
                    .disabled(!canSave)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("New Transaction")
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
            .onAppear {
                // Auto-select first category if available
                if selectedCategoryId == nil, let first = categories.first {
                    selectedCategoryId = first.id
                }
            }
        }
    }
    
    private var canSave: Bool {
        !amount.isEmpty && selectedCategoryId != nil
    }
    
    // Shorten long category names for display
    private func shortName(for name: String) -> String {
        switch name {
        case "Food & Dining": return "Food"
        case "Transportation": return "Transport"
        case "Entertainment": return "Fun"
        case "Bills & Utilities": return "Bills"
        case "Health & Fitness": return "Health"
        case "Personal Care": return "Personal"
        case "Subscriptions": return "Subs"
        default: return name
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let categoryId = selectedCategoryId,
              let category = categories.first(where: { $0.id == categoryId }) else { return }
        
        viewModel.addTransaction(
            amount: amountValue,
            categoryName: category.name,
            description: description,
            date: date
        )
        dismiss()
    }
}

#Preview {
    AddTransactionView(viewModel: HomeViewModel())
}
