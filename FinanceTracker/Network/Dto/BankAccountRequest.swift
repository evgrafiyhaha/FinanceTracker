import Foundation

struct BankAccountRequest: Encodable {
    let name: String
    let balance: String
    let currency: String
}

extension BankAccountRequest {
    init(from model: BankAccount) {
        self.name = model.name
        self.balance = String(format: "%.2f", NSDecimalNumber(decimal: model.balance).doubleValue)
        print(self.balance,model.balance)
        self.currency = model.currency.rawValue
    }
}
