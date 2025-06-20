import SwiftUI

enum TransactionCellContext {
    case history
    case today
}

struct TransactionCell: View {
    var transaction: Transaction
    var context: TransactionCellContext

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
            VStack(alignment: .trailing) {
                Text("\(transaction.amount.formatted()) \(transaction.account.currency.symbol)")
                if context == .history {
                    Text(transaction.transactionDate.formatted(date: .omitted, time: .shortened))
                }
            }

        }
    }
}
