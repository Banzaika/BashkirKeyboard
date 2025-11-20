import UIKit

protocol PopupKeyViewDelegate: AnyObject {
    func popupKeyView(_ view: PopupKeyView, didSelect character: String)
    func popupKeyView(_ view: PopupKeyView, highlightedCharacter: String?)
}

final class PopupKeyView: UIView {
    weak var delegate: PopupKeyViewDelegate?
    
    private var characterLabels: [UILabel] = []
    private var highlightedIndex: Int?
    private var palette: UIKitThemePalette
    private let containerView = UIView()
    private var blurView: UIVisualEffectView?
    
    // Apple-style bubble shape with arrow pointing down to the key
    private let shapeLayer = CAShapeLayer()
    private let bubbleOffset: CGFloat = 12 // Offset above key
    
    // Tracking touch position
    private var lastHighlightedIndex: Int?
    
    init(alternatives: [String], palette: UIKitThemePalette) {
        self.palette = palette
        super.init(frame: .zero)
        setupView()
        configureLabels(with: alternatives)
        setupBubbleShape()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateBubbleShape()
    }
    
    // Convert touch location in container view to highlighted character index
    func updateHighlight(for location: CGPoint) {
        // Convert location to popup's coordinate system
        guard let superview = superview else { return }
        let localLocation = convert(location, from: superview)
        let containerLocation = containerView.convert(localLocation, from: self)
        
        // Allow some tolerance around popup bounds for better sliding experience
        let tolerance: CGFloat = 30
        let expandedBounds = containerView.bounds.insetBy(dx: -tolerance, dy: -tolerance)
        
        // Check if touch is within popup area (with tolerance)
        guard expandedBounds.contains(containerLocation) else {
            // Outside popup - keep last highlight but don't update
            return
        }
        
        // Calculate which character is under the touch
        let buttonWidth = containerView.bounds.width / CGFloat(max(1, characterLabels.count))
        let adjustedX = max(0, min(containerLocation.x, containerView.bounds.width))
        let index = Int(adjustedX / buttonWidth)
        let clampedIndex = max(0, min(index, characterLabels.count - 1))
        
        if clampedIndex != highlightedIndex {
            highlightedIndex = clampedIndex
            updateLabelHighlights()
            if clampedIndex < characterLabels.count {
                let character = characterLabels[clampedIndex].text ?? ""
                delegate?.popupKeyView(self, highlightedCharacter: character)
            }
        }
    }
    
    func selectHighlightedCharacter() {
        guard let index = highlightedIndex, index < characterLabels.count else { return }
        if let character = characterLabels[index].text {
            delegate?.popupKeyView(self, didSelect: character)
        }
    }
    
    func clearHighlight() {
        highlightedIndex = nil
        updateLabelHighlights()
        delegate?.popupKeyView(self, highlightedCharacter: nil)
    }
    
    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = false // Handle touches from parent
        
        // Setup container for content
        containerView.backgroundColor = .clear
        containerView.layer.masksToBounds = false
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Apply blur material if needed
        if let blurStyle = palette.blurStyle {
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            blur.layer.masksToBounds = true
            containerView.addSubview(blur)
            blur.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blur.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                blur.topAnchor.constraint(equalTo: containerView.topAnchor),
                blur.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            blurView = blur
            
            // Add semi-transparent background for glass effect
            let glassView = UIView()
            glassView.backgroundColor = palette.keyBackgroundColor.withAlphaComponent(0.8)
            glassView.layer.masksToBounds = true
            containerView.insertSubview(glassView, belowSubview: blur)
            glassView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                glassView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                glassView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                glassView.topAnchor.constraint(equalTo: containerView.topAnchor),
                glassView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        } else {
            containerView.backgroundColor = palette.keyBackgroundColor
        }
        
        containerView.layer.cornerRadius = palette.keyCornerRadius
        
        // Add shadow for depth
        layer.shadowColor = palette.keyShadowColor.cgColor
        layer.shadowRadius = palette.keyShadowRadius * 2
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: palette.keyShadowOffset.height * 2)
        layer.masksToBounds = false
    }
    
    private func setupBubbleShape() {
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        layer.insertSublayer(shapeLayer, at: 0)
    }
    
    private func updateBubbleShape() {
        guard !characterLabels.isEmpty else { return }
        
        let cornerRadius: CGFloat = palette.keyCornerRadius
        let arrowWidth: CGFloat = 14
        let arrowHeight: CGFloat = 8
        let arrowOffset = bounds.width / 2
        
        let path = UIBezierPath()
        
        // Main bubble body (rounded rectangle)
        let bubbleRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - arrowHeight)
        path.append(UIBezierPath(roundedRect: bubbleRect, cornerRadius: cornerRadius))
        
        // Arrow pointing down (centered)
        let arrowStartX = arrowOffset - arrowWidth / 2
        let arrowEndX = arrowOffset + arrowWidth / 2
        let arrowY = bounds.height - arrowHeight
        
        path.move(to: CGPoint(x: arrowOffset, y: bounds.height))
        path.addLine(to: CGPoint(x: arrowStartX, y: arrowY))
        path.addLine(to: CGPoint(x: arrowEndX, y: arrowY))
        path.close()
        
        shapeLayer.path = path.cgPath
        
        // Fill with background color or clear if using blur
        if palette.blurStyle == nil {
            shapeLayer.fillColor = palette.keyBackgroundColor.cgColor
        } else {
            shapeLayer.fillColor = UIColor.clear.cgColor
        }
    }
    
    private func configureLabels(with alternatives: [String]) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        
        alternatives.forEach { character in
            let label = UILabel()
            label.text = character
            label.font = UIFont.systemFont(ofSize: 26, weight: .regular)
            label.textColor = palette.keyForegroundColor
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            stackView.addArrangedSubview(label)
            characterLabels.append(label)
        }
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bubbleOffset)
        ])
    }
    
    private func updateLabelHighlights() {
        for (index, label) in characterLabels.enumerated() {
            if index == highlightedIndex {
                // Highlighted state: larger, bold, with background
                label.backgroundColor = palette.keyForegroundColor.withAlphaComponent(0.15)
                label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
                label.textColor = palette.keyForegroundColor
                UIView.animate(withDuration: 0.12, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                    label.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            } else {
                // Normal state
                label.backgroundColor = .clear
                label.font = UIFont.systemFont(ofSize: 26, weight: .regular)
                label.textColor = palette.keyForegroundColor
                UIView.animate(withDuration: 0.12) {
                    label.transform = .identity
                }
            }
        }
    }
    
    func animateAppearance() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.85, y: 0.85).translatedBy(x: 0, y: 8)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.6, options: [.curveEaseOut]) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func animateDismissal(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.18, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85).translatedBy(x: 0, y: 8)
        }, completion: { _ in
            completion()
        })
    }
}
