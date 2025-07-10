import UIKit

protocol SortTableViewCellDelegate: AnyObject {
    func sort(withType type: SortingType)
}

final class SortTableViewCell: UITableViewCell {

    // MARK: - Static Properties
    static let reuseIdentifier = "SortTableViewCell"

    // MARK: - Private Properties
    private weak var delegate: SortTableViewCellDelegate?
    private var currentType: SortingType = .date

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Сортировка"
        return label
    }()

    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.accent, for: .normal)
        return button
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
    }

    // MARK: - Public Methods
    func setupCell(withType type: SortingType, delegate: SortTableViewCellDelegate) {
        self.delegate = delegate
        self.currentType = type
        sortButton.setTitle(type.name, for: .normal)
        configureMenu()
    }

    // MARK: - Private Methods
    private func setupSubviews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(sortButton)
    }

    private func setupConstraints() {
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func configureMenu() {
        let dateAction = UIAction(title: SortingType.date.name) { [weak self] _ in
            self?.currentType = .date
            self?.sortButton.setTitle(SortingType.date.name, for: .normal)
            self?.delegate?.sort(withType: .date)
        }

        let amountAction = UIAction(title: SortingType.amount.name) { [weak self] _ in
            self?.currentType = .amount
            self?.sortButton.setTitle(SortingType.amount.name, for: .normal)
            self?.delegate?.sort(withType: .amount)
        }

        let menu = UIMenu(title: "", children: [dateAction, amountAction])
        sortButton.menu = menu
        sortButton.showsMenuAsPrimaryAction = true
    }
}
