import UIKit

//protocol CartTableViewCellDelegate {
//    func present(with id: String, image: UIImage)
//}

final class PickerTableViewCell: UITableViewCell {

    static let reuseIdentifier = "PickerTableViewCell"

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.backgroundColor = .ftLightGreen
        picker.layer.cornerRadius = 6
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
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

    func setupCell(with name: String, delegate: UIViewController) {
        nameLabel.text = name
    }

    private func setupSubviews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(nameLabel)
        contentView.addSubview(datePicker)
    }

    private func setupConstraints() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {

    }
}
