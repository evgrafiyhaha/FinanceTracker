import UIKit
import SwiftUI
import PieChart

enum DatePickerType: String {
    case start = "Период: начало"
    case end = "Период: конец"
}

enum CellType {
    case picker(datePickerType: DatePickerType)
    case sort
    case sum
}

protocol AnalysisViewProtocol: AnyObject {
    func reloadTransactionTableView()
    func reloadPickerTableView()
    func reloadDiagram(with entities: [Entity])
    func showLoader()
    func hideLoader()
    func showError(_ message: String)
}

final class AnalysisViewController: UIViewController {

    // MARK: - Private Properties
    private let presenter: AnalysisPresenterProtocol
    private let cells: [CellType] = [
        .picker(datePickerType: .start),
        .picker(datePickerType: .end),
        .sort,
        .sum
    ]
    private var tableHeightConstraint: NSLayoutConstraint?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var diagramView = UIView()
    private var pieChartView = PieChartView()

    private var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()

    private lazy var tableTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ОПЕРАЦИИ"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private var pickerTableView: UITableView!
    private var transactionTableView: UITableView!

    // MARK: - Init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(presenter: AnalysisPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        presenter.view = self
    }

    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerTableView = makePickerTableView()
        transactionTableView = makeTransactionTableView()
        setupSubviews()
        setupConstraints()
        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ftBackground
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        self.parent?.navigationItem.title = "Анализ"
        self.parent?.navigationController?.navigationBar.prefersLargeTitles = true
        self.parent?.navigationItem.largeTitleDisplayMode = .always
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        view.backgroundColor = .ftBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(pickerTableView)
        contentView.addSubview(diagramView)
        contentView.addSubview(tableTitleLabel)
        contentView.addSubview(transactionTableView)
        view.addSubview(loader)
        diagramView.addSubview(pieChartView)
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        pickerTableView.translatesAutoresizingMaskIntoConstraints = false
        diagramView.translatesAutoresizingMaskIntoConstraints = false
        tableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionTableView.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        pieChartView.translatesAutoresizingMaskIntoConstraints = false

        tableHeightConstraint = transactionTableView.heightAnchor.constraint(equalToConstant: CGFloat(presenter.transactions.count) * 60)
        tableHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            pickerTableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            pickerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pickerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pickerTableView.heightAnchor.constraint(equalToConstant: 176),

            diagramView.topAnchor.constraint(equalTo: pickerTableView.bottomAnchor),
            diagramView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            diagramView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            diagramView.heightAnchor.constraint(equalToConstant: 185),
            pieChartView.widthAnchor.constraint(equalToConstant: 150),
            pieChartView.heightAnchor.constraint(equalToConstant: 145),
            pieChartView.centerXAnchor.constraint(equalTo: diagramView.centerXAnchor),
            pieChartView.centerYAnchor.constraint(equalTo: diagramView.centerYAnchor),

            tableTitleLabel.topAnchor.constraint(equalTo: diagramView.bottomAnchor, constant: 8),
            tableTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            transactionTableView.topAnchor.constraint(equalTo: tableTitleLabel.bottomAnchor, constant: 8),
            transactionTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        let last = cell is TransactionTableViewCell ? presenter.transactions.count-1 : cells.count-1
        if indexPath.row == last {
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        }
    }

    private func makePickerTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(TotalSumTableViewCell.self, forCellReuseIdentifier: TotalSumTableViewCell.reuseIdentifier)
        tableView.register(SortTableViewCell.self, forCellReuseIdentifier: SortTableViewCell.reuseIdentifier)
        tableView.register(PickerTableViewCell.self, forCellReuseIdentifier: PickerTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 10
        tableView.tableHeaderView = UIView()
        return tableView
    }

    private func makeTransactionTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 10
        tableView.tableHeaderView = UIView()
        return tableView
    }
}

// MARK: - UITableView
extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pickerTableView {
            return cells.count
        } else if tableView == transactionTableView {
            return presenter.transactions.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == pickerTableView {
            let type = cells[indexPath.row]
            switch type {
            case .picker(let datePickerType):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.reuseIdentifier, for: indexPath) as? PickerTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupCell(with: datePickerType,for:indexPath.row == 0 ? presenter.startDate : presenter.endDate , delegate: self)
                setupSeparator(for: cell, at: indexPath)
                return cell
            case .sum:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalSumTableViewCell.reuseIdentifier, for: indexPath) as? TotalSumTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupCell(withValue: presenter.sum, for: presenter.bankAccount?.currency)
                setupSeparator(for: cell, at: indexPath)
                return cell
            case .sort:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SortTableViewCell.reuseIdentifier, for: indexPath) as? SortTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupCell(withType: presenter.sortingType, delegate: self)
                setupSeparator(for: cell, at: indexPath)
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.reuseIdentifier, for: indexPath) as? TransactionTableViewCell else {
                return UITableViewCell()
            }
            let transaction = presenter.transactions[indexPath.row]
            let amount = NSDecimalNumber(decimal: transaction.amount)
            let sum = NSDecimalNumber(decimal: presenter.sum)
            let percentDecimal = amount.multiplying(by: 100).dividing(by: sum)
            let percent = percentDecimal.rounding(accordingToBehavior: nil).intValue
            cell.setupCell(with: transaction, percent: percent, delegate: self)
            setupSeparator(for: cell, at: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView == pickerTableView ? 44 : 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == transactionTableView else { return }
        let transaction = presenter.transactions[indexPath.row]
        let swiftUIView = TransactionEditView(
            transaction,
            direction: presenter.direction,
            onSave: { [weak self] in
                self?.transactionTableView.reloadData()
                self?.pickerTableView.reloadData()

            })
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController,animated:true)
    }
}

// MARK: - AnalysisViewProtocol
extension AnalysisViewController: AnalysisViewProtocol {
    func reloadDiagram(with entities: [Entity]) {
        pieChartView.setEntities(entities, animated: true)
    }
    
    func showLoader() {
        loader.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func hideLoader() {
        loader.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }

    func reloadTransactionTableView() {
        transactionTableView.reloadData()
        tableHeightConstraint?.constant = CGFloat(presenter.transactions.count) * 60
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func reloadPickerTableView() {
        pickerTableView.reloadData()
    }
}

// MARK: - PickerTableViewCellDelegate
extension AnalysisViewController: PickerTableViewCellDelegate {
    func updateDate(_ date: Date, for type: DatePickerType) {
        switch type {
        case .start:
            presenter.startDate = date
        case .end:
            presenter.endDate = date
        }
        presenter.load()
    }
}

// MARK: - SortTableViewCellDelegate
extension AnalysisViewController: SortTableViewCellDelegate {
    func sort(withType type: SortingType) {
        presenter.sortingType = type
        presenter.load()
    }
}
