import SwiftUI

struct TransactionEditView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (() async -> Void)
    var direction: Direction
    @FocusState private var isAmountFocused: Bool
    @StateObject var viewModel: TransactionEditViewModel
    @State private var showValidationAlert = false
    @State private var showDeleteConfirmation = false

    init(_ transaction: Transaction?, direction: Direction,onSave: @escaping () async -> Void) {
        self.direction = direction
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: TransactionEditViewModel(transaction, direction: direction))
    }
    var body: some View {
        NavigationStack {
            editList
                .navigationTitle(
                    direction == .income ? "Мои Доходы" : "Мои Расходы"
                )
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Text("Отменить")
                            }
                            .foregroundStyle(.ftPurple)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if viewModel.category == nil || viewModel.amount == nil {
                                showValidationAlert = true
                            } else {
                                Task {
                                    await viewModel.saveTransaction()
                                    dismiss()
                                    await onSave()
                                }
                            }
                        }) {
                            HStack {
                                Text(viewModel.state == .edit ? "Сохранить" : "Создать")
                            }
                            .foregroundStyle(.ftPurple)
                        }
                    }
                }
        }
        .alert("Заполните все поля", isPresented: $showValidationAlert) {
            Button("Ок", role: .cancel) {}
        }
        .alert("Удалить запись?", isPresented: $showDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                Task {
                    await viewModel.deleteTransaction()
                    dismiss()
                    await onSave()
                }
            }
            Button("Отмена", role: .cancel) {}
        } message: {
            Text("Вы уверены, что хотите удалить этот \(direction == .income ? "доход" : "расход")?")
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .withLoadingAndErrorOverlay(
                isLoading: viewModel.isLoading,
                error: viewModel.error,
                onDismiss: { viewModel.error = nil }
            )
        .task { await viewModel.loadData() }
    }
    @ViewBuilder
    var editList: some View {
        List {
            Section {
                HStack {
                    Text("Статья")
                    Spacer()
                    Menu {
                        ForEach(viewModel.categories, id: \.id) { category in
                            Button(action: { viewModel.category = category }) {
                                Text(category.name)
                            }
                        }
                    } label: {
                        HStack {
                            Text(viewModel.category?.name ?? "Не выбрано")
                                .foregroundStyle(Color.ftGray)
                            Image("Drill-in")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack {
                    Text("Сумма")
                    Spacer()
                    TextField("Пусто", text: $viewModel.amountString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                        .focused($isAmountFocused)
                        .onChange(of: isAmountFocused) {
                            if !isAmountFocused {
                                viewModel.updateBalance()
                            }
                        }
                    Text(viewModel.currency.symbol)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Дата")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $viewModel.transactionDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .background(.ftLightGreen)
                }
                HStack {
                    Text("Время")
                    Spacer()
                    DatePicker("", selection: $viewModel.transactionDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .background(.ftLightGreen)
                }
                TextField("Комментарий", text: $viewModel.comment)
                    .multilineTextAlignment(.leading)
            }
            if viewModel.state == .edit {
                Section {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Удалить \(direction == .income ? "доход" : "расход")")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}
