//
//  TransactionDetailView.swift
//  axe-mobile-app
//
//  Transaction detail sheet with edit and delete options
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: TransactionDisplayItem
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedAmount: String = ""
    @State private var editedDescription: String = ""
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    
    // Colors
    private let bgColor = Color(red: 14/255, green: 14/255, blue: 18/255)
    private let cardColor = Color(red: 185/255, green: 255/255, blue: 100/255)
    private let cardDark = Color(red: 26/255, green: 26/255, blue: 30/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                bgColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Transaction Icon
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: transaction.categoryIcon.replacingOccurrences(of: ".fill", with: ""))
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.white.opacity(0.7))
                        )
                        .padding(.top, 20)
                    
                    // Amount
                    if isEditing {
                        HStack {
                            Text("$")
                                .font(.spaceGroteskBold(32))
                                .foregroundColor(.white)
                            TextField("0.00", text: $editedAmount)
                                .font(.spaceGroteskBold(42))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 200)
                        }
                    } else {
                        Text("-$\(String(format: "%.2f", transaction.amount))")
                            .font(.spaceGroteskBold(42))
                            .foregroundColor(.white)
                    }
                    
                    // Details Card
                    VStack(spacing: 0) {
                        // Description
                        DetailRow(
                            icon: "note.text",
                            label: "Note",
                            value: isEditing ? nil : transaction.title
                        ) {
                            if isEditing {
                                TextField("Add a note...", text: $editedDescription)
                                    .font(.spaceGroteskMedium(15))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Date
                        DetailRow(icon: "calendar", label: "Date", value: transaction.dateString)
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Category
                        DetailRow(icon: transaction.categoryIcon, label: "Category", value: nil) {
                            Circle()
                                .fill(transaction.categoryColor)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(cardDark)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        if isEditing {
                            // Save button
                            Button(action: saveChanges) {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Save Changes")
                                }
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(cardColor)
                                .cornerRadius(14)
                            }
                            
                            // Cancel button
                            Button(action: { isEditing = false }) {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                        } else {
                            // Edit button - white outline style
                            Button(action: startEditing) {
                                HStack(spacing: 10) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Edit Transaction")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            
                            // Delete button - red filled style
                            Button(action: { showDeleteConfirm = true }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Delete Transaction")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(14)
                            }
                            .disabled(isDeleting)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 32, height: 32)
                            .background(cardDark)
                            .clipShape(Circle())
                    }
                }
            }
            .alert("Delete Transaction?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTransaction()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private func startEditing() {
        editedAmount = String(format: "%.2f", transaction.amount)
        editedDescription = transaction.title
        isEditing = true
    }
    
    private func saveChanges() {
        guard let amount = Double(editedAmount), amount > 0 else { return }
        
        viewModel.updateTransaction(
            id: transaction.id,
            amount: amount,
            description: editedDescription
        )
        dismiss()
    }
    
    private func deleteTransaction() {
        isDeleting = true
        viewModel.deleteTransaction(id: transaction.id)
        dismiss()
    }
}

// MARK: - Detail Row
struct DetailRow<Content: View>: View {
    let icon: String
    let label: String
    let value: String?
    var content: (() -> Content)? = nil
    
    init(icon: String, label: String, value: String?, @ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
        self.icon = icon
        self.label = label
        self.value = value
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon.replacingOccurrences(of: ".fill", with: ""))
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(.gray)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if let content = content {
                content()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    TransactionDetailView(
        transaction: TransactionDisplayItem(
            id: UUID(),
            title: "Coffee at Starbucks",
            amount: 5.50,
            categoryIcon: "cup.and.saucer.fill",
            categoryColor: .red,
            dateString: "Today",
            date: Date()
        ),
        viewModel: HomeViewModel()
    )
}
