import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController()
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {

    }
}

// MARK: - Preview

#Preview {
    AnalysisView()
}

