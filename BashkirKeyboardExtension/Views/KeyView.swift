import UIKit

protocol KeyViewDelegate: AnyObject {
    func keyViewDidTap(_ keyView: KeyView)
    func keyViewDidLongPress(_ keyView: KeyView, gesture: UILongPressGestureRecognizer)
}

final class KeyView: UIControl {
    let key: KeyboardKey
    weak var delegate: KeyViewDelegate?

    private let titleLabel = UILabel()
    private var palette: UIKitThemePalette

    init(key: KeyboardKey, palette: UIKitThemePalette, isUppercase: Bool) {
        self.key = key
        self.palette = palette
        super.init(frame: .zero)
        setupView()
        updateTitle(isUppercase: isUppercase)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { updateHighlightState() }
    }

    func updateTitle(isUppercase: Bool) {
        titleLabel.text = key.displayText(isUppercase: isUppercase)
        setNeedsLayout()
    }

    func updateTheme(_ palette: UIKitThemePalette) {
        self.palette = palette
        backgroundColor = palette.keyBackgroundColor
        titleLabel.textColor = palette.keyForegroundColor
        layer.cornerRadius = palette.keyCornerRadius
        layer.shadowColor = palette.keyShadowColor.cgColor
        layer.shadowOpacity = Float(palette.keyShadowColor.cgColor.alpha)
        layer.shadowRadius = palette.keyShadowRadius
        layer.shadowOffset = palette.keyShadowOffset
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = palette.keyBackgroundColor
        layer.cornerRadius = palette.keyCornerRadius
        layer.shadowColor = palette.keyShadowColor.cgColor
        layer.shadowRadius = palette.keyShadowRadius
        layer.shadowOffset = palette.keyShadowOffset
        layer.shadowOpacity = 0.2

        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = palette.keyForegroundColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        accessibilityLabel = key.accessibilityLabel
    }

    private func updateHighlightState() {
        let scale: CGFloat = isHighlighted ? 0.95 : 1.0
        UIView.animate(withDuration: 0.08) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.backgroundColor = self.isHighlighted ? self.palette.keyBackgroundColor.withAlphaComponent(0.7) : self.palette.keyBackgroundColor
        }
    }

    @objc private func handleTap() {
        delegate?.keyViewDidTap(self)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        delegate?.keyViewDidLongPress(self, gesture: gesture)
    }
}
