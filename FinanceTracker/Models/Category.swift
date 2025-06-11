struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}

extension Category {
    static func parse(jsonObject: Any) -> Category? {
        guard
            let dict = jsonObject as? [String: Any],
            let id = dict["id"] as? Int,
            let name = dict["name"] as? String,
            let emojiString = dict["emoji"] as? String,
            let emoji = emojiString.first,
            let isIncome = dict["isIncome"] as? Bool
        else { return nil }

        let direction: Direction = isIncome ? .income : .outcome
        return Category(id: id, name: name, emoji: emoji, direction: direction)
    }

    var jsonObject: Any {
        let isIncome = direction == .income
        return [
            "id": id,
            "name": name,
            "emoji": String(emoji),
            "isIncome": isIncome
        ]
    }
}
