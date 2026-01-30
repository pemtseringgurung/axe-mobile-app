//
//  AllTransactionsView.swift
//  axe-mobile-app
//
//  View showing all transactions with search and filter
//

import SwiftUI

struct AllTransactionsView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedTransaction: TransactionDisplayItem?
    @Environment(\.dismiss) private var dismiss
    
    @State private var transactionToDelete: TransactionDisplayItem?
    @State private var showDeleteConfirm = false
    
    // Colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let cardColor = Color(red: 185/255, green: 255/255, blue: 100/255)
    private let cardDark = Color(red: 26/255, green: 26/255, blue: 30/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 36, height: 36)
                                .background(cardDark)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("All Transactions")
                            .font(.spaceGroteskBold(18))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(bgColor)
                    
                    // Hint text
                    HStack {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 12))
                        Text("Tap to edit • Swipe left to delete")
                            .font(.spaceGroteskMedium(12))
                    }
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    
                    if viewModel.transactions.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.gray)
                            
                            Text("No transactions yet")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.transactions) { tx in
                                TransactionListRow(transaction: tx, accent: cardColor)
                                    .listRowBackground(bgColor)
                                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dismiss()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            selectedTransaction = tx
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            transactionToDelete = tx
                                            showDeleteConfirm = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Delete Transaction?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {
                    transactionToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let tx = transactionToDelete {
                        viewModel.deleteTransaction(id: tx.id)
                    }
                    transactionToDelete = nil
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}

// MARK: - Transaction List Row (with chevron)
struct TransactionListRow: View {
    let transaction: TransactionDisplayItem
    let accent: Color
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.categoryIcon.replacingOccurrences(of: ".fill", with: ""))
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
            
            // Chevron to show tappable
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 14)
    }
}

#Preview {
    AllTransactionsView(
        viewModel: HomeViewModel(),
        selectedTransaction: .constant(nil)
    )
}

