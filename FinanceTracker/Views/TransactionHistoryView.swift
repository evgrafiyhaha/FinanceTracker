import SwiftUI


struct TransactionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    var direction: Direction
    @StateObject var viewModel: TransactionHistoryViewModel
    @State private var selectedTransaction: Transaction? = nil

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
                            Button {
                                selectedTransaction = transaction
                            } label: {
                                TransactionCell(
                                    transaction: transaction,
                                    context: .history,
                                    currency: viewModel.bankAccount?.currency ?? .usd
                                )
                                .contentShape(Rectangle())
                                .padding(4)
                            }
                            .buttonStyle(.plain)
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
                    NavigationLink(destination: AnalysisView(direction: direction)) {
                        Image(systemName: "document")
                            .foregroundStyle(.ftPurple)
                    }
                }
            }
        }
        .withLoadingAndErrorOverlay(
                isLoading: viewModel.isLoading,
                error: viewModel.error,
                onDismiss: { viewModel.error = nil }
            )
        .refreshable {
            await viewModel.load()
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionEditView(transaction, direction: direction, onSave: {await viewModel.load()})
        }
        .task {
            viewModel.appState = appState
            await viewModel.load()
        }
        .onChange(of: viewModel.startDate) {
            viewModel.changeDatePeriod()
        }
        .onChange(of: viewModel.endDate) {
            viewModel.changeDatePeriod()
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
