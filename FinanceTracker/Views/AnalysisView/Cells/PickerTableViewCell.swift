import UIKit

protocol PickerTableViewCellDelegate: AnyObject {
    func updateDate(_ date: Date, for type: DatePickerType)
}

final class PickerTableViewCell: UITableViewCell {
    
    // MARK: - Static Properties
    static let reuseIdentifier = "PickerTableViewCell"
    
    // MARK: - Private Properties
    private weak var delegate: PickerTableViewCellDelegate?
    private var type: DatePickerType?
    
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
    
    // MARK: - Init
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
    
    // MARK: - Public Methods
    func setupCell(with type: DatePickerType, for date: Date, delegate: PickerTableViewCellDelegate) {
        self.type = type
        self.delegate = delegate
        nameLabel.text = type.rawValue
        datePicker.setDate(date, animated: false)
    }
    
    // MARK: - Private Methods
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
        guard
            let delegate,
            let type
        else { return }
        delegate.updateDate(sender.date, for: type)
    }
}
