import SwiftUI

struct AccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @State private var isPresented = false
    @FocusState private var isAmountFocused: Bool
    @State var spoilerIsOn = true

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.state == .edit {
                    editList
                } else {
                    viewList
                }
            }
            .navigationTitle("Мой счет")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Group {
                        if viewModel.state == .edit {
                            Button("Сохранить") {
                                hideKeyboard()
                                viewModel.updateBalance(from: viewModel.balanceString)
                                Task {
                                    await viewModel.updateBalanceOnServer()
                                    await viewModel.updateCurrencyOnServer()
                                }

                                withAnimation {
                                    viewModel.state = .view
                                }
                            }
                        } else {
                            Button("Редактировать") {
                                withAnimation {
                                    viewModel.state = .edit
                                }
                            }
                        }
                    }
                    .foregroundStyle(.ftPurple)
                }
            }
        }
        .task {
            await viewModel.fetchAccount()
        }
    }

    var editList: some View {
        ZStack {
            VStack {
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
                .refreshable {
                    await viewModel.fetchAccount()
                }
            }
            if isPresented {
                CurrencyActionSheet(isPresented: $isPresented) { currency in
                    viewModel.currency = currency
                }
            }
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)

    }

    @ViewBuilder
    var viewList: some View {
        VStack {
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
            .refreshable {
                Task {
                    await viewModel.fetchAccount()
                }
            }
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
