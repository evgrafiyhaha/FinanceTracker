import SwiftUI

extension View {
    func withLoadingAndErrorOverlay(
        isLoading: Bool,
        error: String?,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.1)
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .allowsHitTesting(true)

                        ProgressView("Загрузка...")
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                    }
                }
            }
            .alert("Ошибка", isPresented: .constant(error != nil)) {
                Button("Ок", role: .cancel, action: onDismiss)
            } message: {
                Text(error ?? "")
            }
    }
}
