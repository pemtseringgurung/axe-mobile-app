//
//  SetupBudgetView.swift
//  axe-mobile-app
//
//  Minimal modern budget setup
//

import SwiftUI

struct SetupBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var budgetAmount = ""
    
    // Minimal colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let accent = Color(red: 185/255, green: 255/255, blue: 100/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 40) {
                        // Icon - minimal outline
                        ZStack {
                            Circle()
                                .stroke(accent, lineWidth: 2)
                                .frame(width: 72, height: 72)
                            
                            Image(systemName: "chart.pie")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(accent)
                        }
                        .padding(.top, 40)
                        
                        // Title
                        VStack(spacing: 10) {
                            Text("Set Your Budget")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("How much do you want to spend?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        // Amount - minimal
                        VStack(spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("$")
                                    .font(.system(size: 36, weight: .light, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                
                                TextField("0", text: $budgetAmount)
                                    .font(.system(size: 56, weight: .semibold, design: .rounded).monospacedDigit())
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 200)
                            }
                            
                            Text("per month")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        // Quick amounts - outline style
                        VStack(spacing: 16) {
                            Text("QUICK SELECT")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(2)
                            
                            HStack(spacing: 12) {
                                ForEach([500, 1000, 2000, 3000], id: \.self) { amount in
                                    Button(action: { budgetAmount = "\(amount)" }) {
                                        Text("$\(amount)")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(budgetAmount == "\(amount)" ? .black : .white.opacity(0.7))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                budgetAmount == "\(amount)" 
                                                    ? accent 
                                                    : Color.clear
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(budgetAmount == "\(amount)" ? Color.clear : Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Save Button
                    Button(action: saveBudget) {
                        Text("Set Budget")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(budgetAmount.isEmpty ? Color.white.opacity(0.2) : accent)
                            .cornerRadius(14)
                    }
                    .disabled(budgetAmount.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Budget")
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
    
    private func saveBudget() {
        guard let amount = Double(budgetAmount) else { return }
        viewModel.setBudget(amount: amount)
        dismiss()
    }
}

#Preview {
    SetupBudgetView(viewModel: HomeViewModel())
}
