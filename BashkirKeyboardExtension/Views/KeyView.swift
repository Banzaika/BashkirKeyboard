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
    private var hapticGenerator: UIImpactFeedbackGenerator?
    private var spaceHintWorkItem: DispatchWorkItem?
    private var isSpaceHintVisible = false
    
    private var baseBackgroundColor: UIColor {
        if key.kind == .returnKey {
            return palette.returnKeyBackgroundColor
        }
        if isSpecialKey {
            return palette.specialKeyBackgroundColor
        }
        return palette.keyBackgroundColor
    }
    
    private var isSpecialKey: Bool {
        switch key.kind {
        case .numbersToggle, .emoji, .backspace:
            return true
        default:
            return false
        }
    }

    init(key: KeyboardKey, palette: UIKitThemePalette, isUppercase: Bool) {
        self.key = key
        self.palette = palette
        super.init(frame: .zero)
        setupView()
        updateTitle(isUppercase: isUppercase)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.15
        longPress.cancelsTouchesInView = false
        addGestureRecognizer(longPress)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet { 
            updateHighlightState()
            // Trigger haptic feedback on touch down
            if isHighlighted {
                triggerHapticFeedback()
            }
        }
    }

    func updateTitle(isUppercase: Bool) {
        if key.kind == .space {
            titleLabel.text = isSpaceHintVisible ? "Башҡортса" : ""
        } else {
            titleLabel.text = key.displayText(isUppercase: isUppercase)
        }
        setNeedsLayout()
    }

    func updateTheme(_ palette: UIKitThemePalette) {
        self.palette = palette
        applyPalette()
    }
    
    func showSpaceHint(duration: TimeInterval) {
        guard key.kind == .space else { return }
        isSpaceHintVisible = true
        spaceHintWorkItem?.cancel()
        titleLabel.text = "Башҡортса"
        titleLabel.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.titleLabel.alpha = 1
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: 0.25, animations: {
                self.titleLabel.alpha = 0
            }, completion: { _ in
                self.isSpaceHintVisible = false
                self.updateTitle(isUppercase: false)
            })
        }
        
        spaceHintWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // CRITICAL: masksToBounds must be false for shadows to be visible
        layer.masksToBounds = false
        
        applyPalette()

        // System keyboard font size - adjust based on key type
        let fontSize: CGFloat
        switch key.kind {
        case .character:
            fontSize = 22
        case .shift, .backspace, .returnKey:
            fontSize = 20
        case .numbersToggle, .lettersToggle, .symbolToggle:
            fontSize = 18
        case .emoji:
            fontSize = 24 // Emoji key shows emoji icon
        case .space:
            fontSize = 16 // Slightly larger for temporary label
        default:
            fontSize = 20
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = palette.keyForegroundColor
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7

        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        accessibilityLabel = key.accessibilityLabel
    }

    private func triggerHapticFeedback() {
        // Check if haptics are enabled from shared UserDefaults
        let defaults = UserDefaults(suiteName: SharedAppGroup.identifier) ?? .standard
        let hapticsEnabled = defaults.object(forKey: SharedSettingsKeys.hapticsEnabled) as? Bool ?? true
        
        guard hapticsEnabled else { return }
        
        // Prepare generator if needed
        if hapticGenerator == nil {
            hapticGenerator = UIImpactFeedbackGenerator(style: .light)
            hapticGenerator?.prepare()
        }
        
        // Trigger on main thread
        DispatchQueue.main.async { [weak self] in
            self?.hapticGenerator?.impactOccurred()
        }
    }

    private func updateHighlightState() {
        let scale: CGFloat = isHighlighted ? 0.95 : 1.0
        let baseColor = baseBackgroundColor
        let targetColor: UIColor
        if isHighlighted {
            let alpha = max(0.2, CGFloat(baseColor.cgColor.alpha) * 0.85)
            targetColor = baseColor.withAlphaComponent(alpha)
        } else {
            targetColor = baseColor
        }
        UIView.animate(withDuration: 0.08) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.backgroundColor = targetColor
        }
    }

    @objc private func handleTap() {
        delegate?.keyViewDidTap(self)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        delegate?.keyViewDidLongPress(self, gesture: gesture)
    }

    private func applyPalette() {
        backgroundColor = baseBackgroundColor
        titleLabel.textColor = palette.keyForegroundColor
        layer.cornerRadius = palette.keyCornerRadius
        
        // Apply drop shadow for depth
        layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.35
        
        // CRITICAL: masksToBounds must be false for shadows to work
        layer.masksToBounds = false
    }
}
