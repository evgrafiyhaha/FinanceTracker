import UIKit
import SwiftUI

enum CellType {
    case picker(name: String)
    case sum
}

final class AnalysisViewController: UIViewController {

    private var cells: [CellType] = [
        .picker(name: "Период: начало"),
        .picker(name: "Период: конец"),
        .sum
    ]
    private var transactions: [CellType] = [
        .picker(name: "Период: начало"),
        .picker(name: "Период: конец"),
        .sum,
        .picker(name: "Период: начало"),
        .picker(name: "Период: конец"),
        .sum,
        .picker(name: "Период: начало"),
        .picker(name: "Период: конец"),
        .sum
    ]
    private var tableHeightConstraint: NSLayoutConstraint?

    private let scrollView = UIScrollView()

    private var diagramView = UIView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализ"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
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

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerTableView = makePickerTableView()
        transactionTableView = makeTransactionTableView()
        setupSubviews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ftBackground
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private let contentView = UIView()

    private func setupSubviews() {
        view.backgroundColor = .ftBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(pickerTableView)
        contentView.addSubview(diagramView)
        contentView.addSubview(tableTitleLabel)
        contentView.addSubview(transactionTableView)

        diagramView.backgroundColor = .ftLightGreen
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pickerTableView.translatesAutoresizingMaskIntoConstraints = false
        diagramView.translatesAutoresizingMaskIntoConstraints = false
        tableTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionTableView.translatesAutoresizingMaskIntoConstraints = false

        tableHeightConstraint = transactionTableView.heightAnchor.constraint(equalToConstant: CGFloat(transactions.count) * 60)
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

            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            pickerTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            pickerTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pickerTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pickerTableView.heightAnchor.constraint(equalToConstant: 132),

            diagramView.topAnchor.constraint(equalTo: pickerTableView.bottomAnchor),
            diagramView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            diagramView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            diagramView.heightAnchor.constraint(equalToConstant: 185),
            tableTitleLabel.topAnchor.constraint(equalTo: diagramView.bottomAnchor, constant: 8),
            tableTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            transactionTableView.topAnchor.constraint(equalTo: tableTitleLabel.bottomAnchor, constant: 8),
            transactionTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            transactionTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            transactionTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func setupSeparator(for cell: UITableViewCell, at indexPath: IndexPath) {
        if indexPath.row == cells.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        }
    }

    private func makePickerTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(TotalSumTableViewCell.self, forCellReuseIdentifier: TotalSumTableViewCell.reuseIdentifier)
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

    //    @objc private func addItem() {
    //            items.append("\(items.count + 1)")
    //            tableView.reloadData()
    //
    //
    //            tableHeightConstraint?.constant = CGFloat(items.count) * 44
    //            UIView.animate(withDuration: 0.3) {
    //                self.view.layoutIfNeeded()
    //            }
    //        }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == pickerTableView {
            return cells.count
        } else if tableView == transactionTableView {
            return transactions.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == pickerTableView {
            let type = cells[indexPath.row]
            switch type {
            case .picker(let name):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PickerTableViewCell.reuseIdentifier, for: indexPath) as? PickerTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupCell(with: name, delegate: self)
                setupSeparator(for: cell, at: indexPath)
                return cell
            case .sum:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalSumTableViewCell.reuseIdentifier, for: indexPath) as? TotalSumTableViewCell else {
                    return UITableViewCell()
                }
                cell.setupCell(withValue: 0, for: .rub, delegate: self)
                setupSeparator(for: cell, at: indexPath)
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.reuseIdentifier, for: indexPath) as? TransactionTableViewCell else {
                return UITableViewCell()
            }
            cell.setupCell(with: TransactionsService().transactions[indexPath.row], percent: 7, delegate: self)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView == pickerTableView ? 44 : 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == transactionTableView else { return }
        let swiftUIView = TransactionEditView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}
