import SwiftUI

struct TransactionsListView: View {
    var direction: Direction
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel:TransactionsViewModel
    @State private var selectedTransaction: Transaction? = nil
    @State private var isCreatingTransaction = false


    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionsViewModel(direction: direction))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section {
                        HStack{
                            Text("Всего")
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
                                    context: .today,
                                    currency: viewModel.bankAccount?.currency ?? .usd
                                )
                                .contentShape(Rectangle())
                                .padding(4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                Button {
                    isCreatingTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 16,height: 16)
                        .padding(22)
                        .foregroundStyle(.white)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            .navigationBarTitle(
                direction == .income ? "Доходы сегодня" : "Расходы сегодня"
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TransactionHistoryView(direction: direction)) {
                        Image(systemName: "clock")
                            .foregroundStyle(.ftPurple)
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionEditView(transaction, direction: direction, onSave: {await viewModel.load()})
        }
        .fullScreenCover(isPresented: $isCreatingTransaction) {
            TransactionEditView(nil, direction: direction, onSave: {await viewModel.load()})
        }
        .refreshable {
            await viewModel.load()
        }
        .withLoadingAndErrorOverlay(
                isLoading: viewModel.isLoading,
                error: viewModel.error,
                onDismiss: { viewModel.error = nil }
            )
        .task {
            viewModel.appState = appState
            await viewModel.load()
        }
    }
}

// MARK: - Preview

#Preview {
    TransactionsListView(direction: .income)
}
