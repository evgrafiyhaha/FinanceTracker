import Foundation

extension Decimal {
    func formatted(_ fractionDigits: Int = 3) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        formatter.numberStyle = .decimal
        return formatter.string(for: self) ?? "\(self)"
    }
}
