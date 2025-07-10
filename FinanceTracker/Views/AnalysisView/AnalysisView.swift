import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    var direction: Direction
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController(presenter: AnalysisPresenter(direction: direction))
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {

    }
}
