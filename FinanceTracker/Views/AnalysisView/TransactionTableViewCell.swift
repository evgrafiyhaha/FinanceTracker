import UIKit

//protocol CartTableViewCellDelegate {
//    func present(with id: String, image: UIImage)
//}

final class TransactionTableViewCell: UITableViewCell {

    static let reuseIdentifier = "TransactionTableViewCell"

    private var transaction: Transaction?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()

    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, commentLabel])
        stackView.axis = .vertical
        //stackView.spacing =
        return stackView
    }()

    private lazy var circleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .ftLightGreen
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14.5, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    private lazy var percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .ftGray
        return imageView
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupSubviews()
        setupConstraints()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubviews()
        setupConstraints()
    }

    func setupCell(with transaction: Transaction, percent percentage: Int, delegate: UIViewController) {
        titleLabel.text = transaction.category.name
        commentLabel.text = transaction.comment
        emojiLabel.text = String(transaction.category.emoji)
        percentageLabel.text = "\(percentage)%"
        amountLabel.text = "\(transaction.amount.formatted()) \(transaction.account.currency.symbol)"
    }

    private func setupSubviews() {
        contentView.backgroundColor = .white
        contentView.addSubview(textStackView)
        contentView.addSubview(circleView)
        circleView.addSubview(emojiLabel)
        contentView.addSubview(percentageLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(chevronImageView)
    }

    private func setupConstraints() {
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            emojiLabel.leadingAnchor.constraint(greaterThanOrEqualTo: circleView.leadingAnchor, constant: 2),
            emojiLabel.trailingAnchor.constraint(lessThanOrEqualTo: circleView.trailingAnchor, constant: -2),
            emojiLabel.topAnchor.constraint(greaterThanOrEqualTo: circleView.topAnchor, constant: 2),
            emojiLabel.bottomAnchor.constraint(lessThanOrEqualTo: circleView.bottomAnchor, constant: -2),

            circleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 22),
            circleView.heightAnchor.constraint(equalToConstant: 22),

            textStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStackView.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(lessThanOrEqualTo: percentageLabel.leadingAnchor,constant: 8),

            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: textStackView.centerYAnchor),

            percentageLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            percentageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            amountLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}
