import SwiftUI

struct TransactionsListView: View {
    var direction: Direction
    @StateObject var viewModel:TransactionsViewModel
    
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
                            NavigationLink(destination: TransactionEditView()) {
                                TransactionCell(transaction: transaction)
                            }
                        }
                    }
                }
                NavigationLink(destination: TransactionEditView()) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 16,height: 16)
                        .padding(22)
                        .foregroundStyle(.white)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
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
        .onAppear {
            viewModel.load()
        }
    }
}

struct TransactionCell: View {
    var transaction: Transaction
    var body: some View {
        HStack {
            Text(String(transaction.category.emoji))
                .font(.system(size: 14.5))
                .padding(4)
                .background(.ftLightGreen)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                    .font(.system(size: 17, weight: .regular))
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(transaction.amount.formatted()) \(transaction.account.currency.symbol)")
                .padding(5)
            
            
        }
    }
}
// MARK: - Preview

#Preview {
    TransactionsListView(direction: .income)
}
