import Foundation

final class TransactionsFileCache {

    // MARK: - Private Properties
    private(set) var transactions: [Transaction] = []
    private let fileURL: URL?

    // MARK: - init
    init(fileName: String) {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            print("[TransactionsFileCache.init] - Не удалось получить директорию документов")
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

    // MARK: - Public Methods
    func add(_ transaction: Transaction) {
        guard
            !transactions.contains(where: {transaction.id == $0.id})
        else {
            print("[TransactionsFileCache.add] - Транзакция с id \(transaction.id) уже существует")
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
        guard let fileURL else {
            print("[TransactionsFileCache.save] - fileURL отсутствует")
            return
        }

        let jsonObjects = transactions.map { $0.jsonObject }

        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObjects, options: [.prettyPrinted])
            try data.write(to: fileURL)
        } catch {
            print("[TransactionsFileCache.save] - Ошибка при сохранении: \(error)")
        }
    }

    func load() {
        guard let fileURL else {
            print("[TransactionsFileCache.load] - fileURL отсутствует")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let rawJson = try JSONSerialization.jsonObject(with: data, options: [])

            guard let jsonArray = rawJson as? [[String : Any]] else {
                print("[TransactionsFileCache.load] - Данные не являются массивом JSON-объектов")
                return
            }

            transactions = jsonArray.compactMap { Transaction.parse(jsonObject: $0) }
        } catch {
            print("[TransactionsFileCache.load] - Ошибка при загрузке: \(error)")
        }
    }
}
