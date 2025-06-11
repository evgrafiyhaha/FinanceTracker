import Foundation

final class TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    private let fileURL: URL?

    init(fileName: String) {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            self.fileURL = nil
            return
        }

        let fileURL = directory.appendingPathComponent(fileName)
        self.fileURL = fileURL
        if fileManager.fileExists(atPath: fileURL.path) {
            load()
        } else {
            transactions = []
            save()
        }
    }

    func add(_ transaction: Transaction) {
        guard
            !transactions.contains(where: {transaction.id == $0.id})
        else {
            print("Ошибка создания транзакции: такая транзакция уже существует")
            return
        }
        transactions.append(transaction)
        save()
    }

    func delete(withId id: Int) {
        transactions.removeAll { $0.id == id }
        save()
    }

    func save() {
        guard let fileURL else { return }

        let jsonObjects = transactions.map { $0.jsonObject }

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObjects, options: [.prettyPrinted])
            try data.write(to: fileURL)
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
    }

    func load() {
        guard let fileURL else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let rawJson = try JSONSerialization.jsonObject(with: data, options: [])

            guard let jsonArray = rawJson as? [[String : Any]] else { return }

            transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
        } catch {
            print("Ошибка при загрузке: \(error)")
        }
    }
}
