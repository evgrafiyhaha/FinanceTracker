import SwiftUI


struct TransactionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    var direction: Direction
    @StateObject var viewModel: TransactionHistoryViewModel

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionHistoryViewModel(direction: direction))
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        HStack {
                            Text("Начало")
                            Spacer()
                            DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                                .labelsHidden()
                                .background(.ftLightGreen)
                        }
                        HStack {
                            Text("Конец")
                            Spacer()
                            DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
                                .labelsHidden()
                                .background(.ftLightGreen)
                        }
                        HStack {
                            Text("Сортировка")
                            Spacer()
                            Menu {
                                Button(action: { viewModel.sortingType = .date }) {
                                    Text(SortingType.date.name)
                                }
                                Button(action: { viewModel.sortingType = .amount }) {
                                    Text(SortingType.amount.name)
                                }
                            } label: {
                                Text(viewModel.sortingType.name)
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        HStack {
                            Text("Сумма")
                            Spacer()
                            Text("\(viewModel.sum.formatted()) \(viewModel.bankAccount?.currency.symbol ?? "")")
                        }
                    }
                    Section(header: Text("Операции")) {
                        ForEach(viewModel.transactions, id: \.id) { transaction in
                            NavigationLink(destination: TransactionEditView()) {
                                TransactionCell(transaction: transaction)
                                    .padding(4)
                            }
                        }
                    }

                }
            }
            .navigationTitle("Моя История")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Назад")
                        }
                        .foregroundStyle(.ftPurple)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AnalysisView()) {
                        Image(systemName: "document")
                            .foregroundStyle(.ftPurple)
                    }
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
        .onChange(of: viewModel.startDate) {
            Task { await viewModel.fetchTransactions() }
        }
        .onChange(of: viewModel.endDate) {
            Task { await viewModel.fetchTransactions() }
        }
        .onChange(of: viewModel.sortingType) {
            viewModel.applySort()
        }
    }
}

// MARK: - Preview

#Preview {
    TransactionHistoryView(direction: .income)
}
