import UIKit

protocol PopupKeyViewDelegate: AnyObject {
    func popupKeyView(_ view: PopupKeyView, didSelect character: String)
}

final class PopupKeyView: UIView {
    weak var delegate: PopupKeyViewDelegate?

    private let stackView = UIStackView()
    private var palette: UIKitThemePalette

    init(alternatives: [String], palette: UIKitThemePalette) {
        self.palette = palette
        super.init(frame: .zero)
        setupView()
        configureButtons(with: alternatives)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = palette.keyCornerRadius
        layer.shadowColor = palette.keyShadowColor.cgColor
        layer.shadowRadius = palette.keyShadowRadius
        layer.shadowOpacity = 0.2
        layer.shadowOffset = palette.keyShadowOffset

        if let blurStyle = palette.blurStyle {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            blurView.layer.cornerRadius = palette.keyCornerRadius
            blurView.layer.masksToBounds = true
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            blurView.contentView.addSubview(stackView)
        } else {
            backgroundColor = palette.keyBackgroundColor
            addSubview(stackView)
        }

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    private func configureButtons(with alternatives: [String]) {
        alternatives.forEach { character in
            let button = UIButton(type: .system)
            button.setTitle(character, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
            button.setTitleColor(palette.keyForegroundColor, for: .normal)
            button.addTarget(self, action: #selector(handleSelection(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    @objc private func handleSelection(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        delegate?.popupKeyView(self, didSelect: title)
    }
}
