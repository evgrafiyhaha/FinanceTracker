import SwiftUI

struct CurrencyActionSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onSelect: (Currency) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }

        let alert = UIAlertController(title: "Валюта", message: nil, preferredStyle: .actionSheet)

        let currencies: [Currency] = Currency.allCases

        for currency in currencies {
            let action = UIAlertAction(
                title: "\(currency.name) \(currency.symbol)",
                style: .default,
                handler: { _ in
                    onSelect(currency)
                    isPresented = false
                }
            )
            action.setValue(UIColor.ftPurple, forKey: "titleTextColor")
            alert.addAction(action)
        }

        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true)
        }
    }
}
