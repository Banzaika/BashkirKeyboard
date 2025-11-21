import UIKit

protocol KeyboardViewDelegate: AnyObject {
    func keyboardView(_ view: KeyboardView, didTap key: KeyboardKey)
    func keyboardView(_ view: KeyboardView, didLongPress key: KeyboardKey, from keyView: KeyView, gesture: UILongPressGestureRecognizer)
}

final class KeyboardView: UIView {
    weak var delegate: KeyboardViewDelegate?

    private let contentStackView = UIStackView()
    private let mainAreaContainer = UIView()
    private let letterRowsStackView = UIStackView()
    private let bottomRowStackView = UIStackView()
    private let emojiPanelView = EmojiPanelView()
    private var palette: UIKitThemePalette
    private var keyViews: [UUID: KeyView] = [:]
    private var blurView: UIVisualEffectView?
    private var areaRatioConstraint: NSLayoutConstraint?

    init(palette: UIKitThemePalette) {
        self.palette = palette
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func apply(rows: [KeyboardRow],
               state: KeyboardState,
               palette: UIKitThemePalette,
               showingEmojiPanel: Bool = false,
               emojiCharacters: [String] = []) {
        self.palette = palette
        keyViews.removeAll()
        letterRowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bottomRowStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emojiPanelView.updatePalette(palette)

        applyBackgroundIfNeeded()

        if showingEmojiPanel {
            letterRowsStackView.isHidden = true
            emojiPanelView.isHidden = false
            emojiPanelView.updateEmojis(emojiCharacters)
        } else {
            letterRowsStackView.isHidden = false
            emojiPanelView.isHidden = true
            let topRows = Array(rows.dropLast())
            topRows.enumerated().forEach { index, row in
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.spacing = 6
                rowStack.alignment = .fill
                rowStack.distribution = .fillEqually

                row.keys.forEach { key in
                    let keyView = KeyView(key: key, palette: palette, isUppercase: state.isUppercase)
                    keyView.delegate = self
                    keyViews[key.id] = keyView
                    rowStack.addArrangedSubview(keyView)
                    
                    // Width is 68% of height for the first three letter rows to get consistent sizing
                    keyView.widthAnchor.constraint(equalTo: keyView.heightAnchor, multiplier: 0.68).isActive = true
                }

                letterRowsStackView.addArrangedSubview(rowStack)
            }
        }
        
        let bottomRow = rows.last
        if let bottomRow {
            bottomRow.keys.forEach { key in
                let keyView = KeyView(key: key, palette: palette, isUppercase: state.isUppercase)
                keyView.delegate = self
                keyViews[key.id] = keyView
                bottomRowStackView.addArrangedSubview(keyView)
            }
            applyBottomRowConstraints(on: bottomRowStackView)
        }
    }

    func update(state: KeyboardState) {
        keyViews.values.forEach { $0.updateTitle(isUppercase: state.isUppercase) }
    }

    func updateTheme(_ palette: UIKitThemePalette) {
        self.palette = palette
        backgroundColor = palette.backgroundColor
        keyViews.values.forEach { $0.updateTheme(palette) }
        emojiPanelView.updatePalette(palette)
        applyBackgroundIfNeeded()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 8
        contentStackView.distribution = .fill
        addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainAreaContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomRowStackView.axis = .horizontal
        bottomRowStackView.spacing = 6
        bottomRowStackView.alignment = .fill
        bottomRowStackView.distribution = .fill
        bottomRowStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(mainAreaContainer)
        contentStackView.addArrangedSubview(bottomRowStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
        
        letterRowsStackView.axis = .vertical
        letterRowsStackView.spacing = 8
        letterRowsStackView.distribution = .fillEqually
        letterRowsStackView.alignment = .fill
        letterRowsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        mainAreaContainer.addSubview(letterRowsStackView)
        mainAreaContainer.addSubview(emojiPanelView)
        emojiPanelView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            letterRowsStackView.leadingAnchor.constraint(equalTo: mainAreaContainer.leadingAnchor),
            letterRowsStackView.trailingAnchor.constraint(equalTo: mainAreaContainer.trailingAnchor),
            letterRowsStackView.topAnchor.constraint(equalTo: mainAreaContainer.topAnchor),
            letterRowsStackView.bottomAnchor.constraint(equalTo: mainAreaContainer.bottomAnchor),
            
            emojiPanelView.leadingAnchor.constraint(equalTo: mainAreaContainer.leadingAnchor),
            emojiPanelView.trailingAnchor.constraint(equalTo: mainAreaContainer.trailingAnchor),
            emojiPanelView.topAnchor.constraint(equalTo: mainAreaContainer.topAnchor),
            emojiPanelView.bottomAnchor.constraint(equalTo: mainAreaContainer.bottomAnchor)
        ])
        
        emojiPanelView.isHidden = true
        emojiPanelView.onEmojiSelected = { [weak self] emoji in
            guard let self else { return }
            let key = KeyboardKey(kind: .character(emoji))
            self.delegate?.keyboardView(self, didTap: key)
        }
        
        areaRatioConstraint = mainAreaContainer.heightAnchor.constraint(equalTo: bottomRowStackView.heightAnchor, multiplier: 3.0)
        areaRatioConstraint?.isActive = true

        applyBackgroundIfNeeded()
    }

    private func applyBackgroundIfNeeded() {
        blurView?.removeFromSuperview()
        blurView = nil

        if let blurStyle = palette.blurStyle {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            blur.translatesAutoresizingMaskIntoConstraints = false
            insertSubview(blur, belowSubview: contentStackView)
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
    
    func triggerSpaceHint(duration: TimeInterval) {
        let spaceKeyView = bottomRowStackView.arrangedSubviews.compactMap { $0 as? KeyView }.first(where: { $0.key.kind == .space })
        spaceKeyView?.showSpaceHint(duration: duration)
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

private final class EmojiPanelView: UIView {
    var onEmojiSelected: ((String) -> Void)?
    private var emojiButtons: [UIButton] = []
    private let stackView = UIStackView()
    private var emojis: [String] = []
    private var palette: UIKitThemePalette?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateEmojis(_ emojis: [String]) {
        self.emojis = emojis.isEmpty ? ["😀", "😁", "😂", "🤣", "😊", "😍", "😘", "🥰", "😎", "🤩", "😭", "😡"] : emojis
        rebuildButtons()
    }
    
    func updatePalette(_ palette: UIKitThemePalette) {
        self.palette = palette
        backgroundColor = palette.backgroundColor
        emojiButtons.forEach { button in
            button.setTitleColor(palette.keyForegroundColor, for: .normal)
            button.backgroundColor = palette.keyBackgroundColor.withAlphaComponent(0.6)
        }
    }
    
    private func setup() {
        clipsToBounds = false
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
        
        updateEmojis([])
    }
    
    private func rebuildButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emojiButtons.removeAll()
        
        let chunkSize = 6
        stride(from: 0, to: emojis.count, by: chunkSize).forEach { start in
            let rowEmojis = Array(emojis[start..<min(start + chunkSize, emojis.count)])
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 6
            row.distribution = .fillEqually
            rowEmojis.forEach { emoji in
                let button = UIButton(type: .system)
                button.setTitle(emoji, for: .normal)
                button.setTitleColor(palette?.keyForegroundColor ?? .label, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
                button.backgroundColor = palette?.keyBackgroundColor.withAlphaComponent(0.6) ?? UIColor.secondarySystemBackground
                button.layer.cornerRadius = 8
                button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
                row.addArrangedSubview(button)
                emojiButtons.append(button)
            }
            stackView.addArrangedSubview(row)
        }
    }
    
    @objc private func handleTap(_ button: UIButton) {
        guard let title = button.title(for: .normal) else { return }
        onEmojiSelected?(title)
    }
}
