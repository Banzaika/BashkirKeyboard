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

        rows.enumerated().forEach { rowIndex, row in
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.alignment = .fill
            
            let isBottomRow = isPrimaryBottomRow(row)
            let isLetterRow = rowIndex < 3 // Rows 0, 1, 2 are letter rows
            
            // Use fillEqually for letter rows, fill for bottom row with specific ratios
            rowStack.distribution = isBottomRow ? .fill : .fillEqually

            row.keys.enumerated().forEach { keyIndex, key in
                let keyView = KeyView(key: key, palette: palette, isUppercase: state.isUppercase)
                keyView.delegate = self
                keyViews[key.id] = keyView
                rowStack.addArrangedSubview(keyView)
                
                // Apply width = 0.68 * height ratio for letter rows only
                if isLetterRow {
                    keyView.widthAnchor.constraint(equalTo: keyView.heightAnchor, multiplier: 0.68).isActive = true
                }
            }

            // Apply bottom row constraints AFTER all keys are added
            if isBottomRow {
                applyBottomRowConstraints(on: rowStack)
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
        applyBackgroundIfNeeded()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        rowsStackView.axis = .vertical
        rowsStackView.spacing = 10
        rowsStackView.distribution = .fillEqually
        rowsStackView.alignment = .fill
        addSubview(rowsStackView)
        rowsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            rowsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
            rowsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
            rowsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            rowsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
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

    private func isPrimaryBottomRow(_ row: KeyboardRow) -> Bool {
        guard row.keys.count == 4 else { return false }
        return row.keys[0].kind == .numbersToggle &&
               row.keys[1].kind == .emoji &&
               row.keys[2].kind == .space &&
               row.keys[3].kind == .returnKey
    }

    private func applyBottomRowConstraints(on rowStack: UIStackView) {
        let keyViewsInRow = rowStack.arrangedSubviews.compactMap { $0 as? KeyView }
        guard keyViewsInRow.count == 4 else { return }
        
        let numbersKey = keyViewsInRow[0]
        let emojiKey = keyViewsInRow[1]
        let spaceKey = keyViewsInRow[2]
        let returnKey = keyViewsInRow[3]

        // Remove any existing width constraints that might conflict
        numbersKey.removeConstraints(numbersKey.constraints.filter { $0.firstAttribute == .width })
        emojiKey.removeConstraints(emojiKey.constraints.filter { $0.firstAttribute == .width })
        spaceKey.removeConstraints(spaceKey.constraints.filter { $0.firstAttribute == .width })
        returnKey.removeConstraints(returnKey.constraints.filter { $0.firstAttribute == .width })

        // Apply width ratio: 1 : 1 : 4.45 : 2.2
        emojiKey.widthAnchor.constraint(equalTo: numbersKey.widthAnchor).isActive = true
        spaceKey.widthAnchor.constraint(equalTo: numbersKey.widthAnchor, multiplier: 4.45).isActive = true
        returnKey.widthAnchor.constraint(equalTo: numbersKey.widthAnchor, multiplier: 2.2).isActive = true
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
