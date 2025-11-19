import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func keyboardView(_ view: KeyboardView, didTap key: KeyboardKey)
    func keyboardView(_ view: KeyboardView, didLongPress key: KeyboardKey, from keyView: KeyView, gesture: UILongPressGestureRecognizer)
}

final class KeyboardView: UIView {
    weak var delegate: KeyboardViewDelegate?

    private let rowsStackView = UIStackView()
    private var palette: UIKitThemePalette
    private var keyViews: [UUID: KeyView] = [:]
    private var blurView: UIVisualEffectView?

    init(palette: UIKitThemePalette) {
        self.palette = palette
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(rows: [KeyboardRow], state: KeyboardState, palette: UIKitThemePalette) {
        self.palette = palette
        rowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        keyViews.removeAll()

        applyBackgroundIfNeeded()

        rows.forEach { row in
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually

            row.keys.forEach { key in
                let keyView = KeyView(key: key, palette: palette, isUppercase: state.isUppercase)
                keyView.delegate = self
                keyViews[key.id] = keyView
                rowStack.addArrangedSubview(keyView)

                if key.kind == .space {
                    keyView.widthAnchor.constraint(equalTo: rowStack.widthAnchor, multiplier: 0.5).isActive = true
                }
            }

            rowsStackView.addArrangedSubview(rowStack)
        }
    }

    func update(state: KeyboardState) {
        keyViews.values.forEach { $0.updateTitle(isUppercase: state.isUppercase) }
    }

    func updateTheme(_ palette: UIKitThemePalette) {
        self.palette = palette
        backgroundColor = palette.backgroundColor
        keyViews.values.forEach { $0.updateTheme(palette) }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        rowsStackView.axis = .vertical
        rowsStackView.spacing = 8
        addSubview(rowsStackView)
        rowsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            rowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            rowsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            rowsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])

        applyBackgroundIfNeeded()
    }

    private func applyBackgroundIfNeeded() {
        blurView?.removeFromSuperview()
        blurView = nil

        if let blurStyle = palette.blurStyle {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            blur.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(blur, belowSubview: rowsStackView)
            NSLayoutConstraint.activate([
                blur.leadingAnchor.constraint(equalTo: leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: trailingAnchor),
                blur.topAnchor.constraint(equalTo: topAnchor),
                blur.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            blurView = blur
            backgroundColor = .clear
        } else {
            backgroundColor = palette.backgroundColor
        }
    }
}

extension KeyboardView: KeyViewDelegate {
    func keyViewDidTap(_ keyView: KeyView) {
        delegate?.keyboardView(self, didTap: keyView.key)
    }

    func keyViewDidLongPress(_ keyView: KeyView, gesture: UILongPressGestureRecognizer) {
        delegate?.keyboardView(self, didLongPress: keyView.key, from: keyView, gesture: gesture)
    }
}
