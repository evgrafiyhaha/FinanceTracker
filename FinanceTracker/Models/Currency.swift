enum Currency: String {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"

    var symbol: String {
        switch self {
        case .rub:
            return "₽"
        case .usd:
            return "$"
        case .eur:
            return "€"
        }
    }
}
