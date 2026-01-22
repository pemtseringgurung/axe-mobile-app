//
//  AddTransactionView.swift
//  axe-mobile-app
//
//  Minimal modern transaction entry
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var amount = ""
    @State private var description = ""
    @State private var selectedCategory = 0
    @State private var date = Date()
    
    // Minimal colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    private let categories = [
        ("Food", "cup.and.saucer"),
        ("Transport", "tram"),
        ("Shopping", "handbag"),
        ("Fun", "gamecontroller"),
        ("Bills", "creditcard"),
        ("Other", "square.grid.2x2")
    ]
    
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
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("$")
                                        .font(.system(size: 36, weight: .light, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                    
                                    TextField("0", text: $amount)
                                        .font(.system(size: 56, weight: .semibold, design: .rounded).monospacedDigit())
                                        .foregroundColor(.white)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: 200)
                                }
                            }
                            .padding(.top, 32)
                            
                            // Category - outline style
                            VStack(alignment: .leading, spacing: 16) {
                                Text("CATEGORY")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                    .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(0..<categories.count, id: \.self) { index in
                                            VStack(spacing: 10) {
                                                ZStack {
                                                    Circle()
                                                        .stroke(selectedCategory == index ? accent : Color.white.opacity(0.2), lineWidth: 1.5)
                                                        .frame(width: 52, height: 52)
                                                    
                                                    Image(systemName: categories[index].1)
                                                        .font(.system(size: 20, weight: .light))
                                                        .foregroundColor(selectedCategory == index ? accent : .white.opacity(0.6))
                                                }
                                                
                                                Text(categories[index].0)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(selectedCategory == index ? .white : .gray)
                                            }
                                            .onTapGesture { 
                                                withAnimation(.easeOut(duration: 0.15)) {
                                                    selectedCategory = index 
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
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                VStack(spacing: 0) {
                                    ZStack(alignment: .leading) {
                                        if description.isEmpty {
                                            Text("What was this for?")
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                        
                                        TextField("", text: $description)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 12)
                                    
                                    Rectangle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(height: 1)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Date - modern capsule style
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DATE")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.gray)
                                    .tracking(2)
                                
                                HStack {
                                    DatePicker("", selection: $date, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .tint(accent)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .light))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
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
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(amount.isEmpty ? Color.white.opacity(0.2) : accent)
                            .cornerRadius(14)
                    }
                    .disabled(amount.isEmpty)
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
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        let fullNames = ["Food & Dining", "Transportation", "Shopping", "Entertainment", "Bills", "Other"]
        viewModel.addTransaction(
            amount: amountValue,
            category: fullNames[selectedCategory],
            description: description,
            date: date
        )
        dismiss()
    }
}

#Preview {
    AddTransactionView(viewModel: HomeViewModel())
}
