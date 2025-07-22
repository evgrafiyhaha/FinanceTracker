import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = AccountViewModel()
    @State private var isPresented = false
    @FocusState private var isAmountFocused: Bool
    @State var spoilerIsOn = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .edit:
                    editBody
                case .view:
                    viewBody
                }
            }
            .refreshable {
                await viewModel.fetchAccount()
            }
            .background(
                ShakeDetector {
                    spoilerIsOn.toggle()
                }
            )
            .navigationTitle("Мой счет")
            .toolbar {
                reductButton
            }
            .withLoadingAndErrorOverlay(
                    isLoading: viewModel.isLoading,
                    error: viewModel.error,
                    onDismiss: { viewModel.error = nil }
                )
        }
        .animation(.easeInOut, value: viewModel.state)
        .task {
            viewModel.appState = appState
            await viewModel.fetchAccount()
        }
    }

    private var editBody: some View {
        ZStack {
            VStack {
                editList
            }
            if isPresented {
                CurrencyActionSheet(isPresented: $isPresented) { currency in
                    viewModel.currency = currency
                }
            }
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)

    }

    private var viewBody: some View {
        List {
            Section {
                HStack {
                    Text("💰")
                    Text("Баланс")
                    Spacer()
                    Text("\(viewModel.balance.formatted()) \(viewModel.currency.symbol)")
                        .spoiler(isOn: $spoilerIsOn)
                }
                .listRowBackground(Color.accent)
            }
            Section {
                HStack {
                    Text("Валюта")
                    Spacer()
                    Text(viewModel.currency.symbol)
                }
                .listRowBackground(Color.ftLightGreen)
            }

        }
        .listSectionSpacing(16)
        .transition(.opacity)

    }

    private var editList: some View {
        List {
            Section {
                HStack {
                    Text("💰")
                    Text("Баланс")
                    Spacer()
                    TextField("Баланс", text: $viewModel.balanceString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.secondary)
                        .focused($isAmountFocused)
                        .onChange(of: isAmountFocused) {
                            if !isAmountFocused {
                                viewModel.updateBalance(from: viewModel.balanceString)
                            }
                        }
                }
            }
            Section {
                Button {
                    isPresented = true
                } label: {
                    HStack {
                        Text("Валюта")
                        Spacer()
                        Text(viewModel.currency.symbol)
                            .foregroundStyle(.secondary)
                        Image("Drill-in")
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

        }
        .listSectionSpacing(16)
        .transition(.opacity)
    }

    private var reductButton: ToolbarItem<(), some View> {
        ToolbarItem(placement: .navigationBarTrailing) {
            Group {
                switch viewModel.state {
                case .edit:
                    Button("Сохранить") {
                        hideKeyboard()
                        viewModel.updateBalance(from: viewModel.balanceString)
                        viewModel.saveChanges()
                        viewModel.state = .view
                    }
                case .view:
                    Button("Редактировать") {
                        viewModel.state = .edit
                    }
                }
            }
            .foregroundStyle(.ftPurple)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.hideKeyboard()
    }
}

// MARK: - Preview

#Preview {
    AccountView()
}
