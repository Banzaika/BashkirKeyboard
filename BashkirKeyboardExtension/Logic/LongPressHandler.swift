import UIKit
import SwiftUI

final class LongPressHandler: PopupKeyViewDelegate {
    weak var containerView: UIView?
    var onCharacterSelected: ((String) -> Void)?
    var haptics: HapticFeedbackManager?
    var popupDelay: TimeInterval = 0.2
    private var popupView: PopupKeyView?
    private var palette: UIKitThemePalette?
    private weak var sourceKeyView: KeyView?
    private var gestureRecognizer: UILongPressGestureRecognizer?
    
    // Touch tracking for sliding selection
    private var panGesture: UIPanGestureRecognizer?
    private var lastHighlightedCharacter: String?
    private var expansionWorkItem: DispatchWorkItem?
    private var popupHostView: UIView?
    private var baseCharacter: String?
    private var currentAnchorFrame: CGRect = .zero
    private var isExpanded = false
    private var currentCharacters: [String] = []
    
    func handle(gesture: UILongPressGestureRecognizer,
                keyView: KeyView,
                baseValue: String,
                alternatives: AlternativeCharactersProvider.Alternatives?,
                isUppercase: Bool,
                palette: UIKitThemePalette) {
        self.palette = palette
        self.sourceKeyView = keyView
        self.gestureRecognizer = gesture
        self.baseCharacter = isUppercase ? baseValue.uppercased() : baseValue.lowercased()
        
        switch gesture.state {
        case .began:
            showInitialPopup(from: keyView)
            scheduleExpansion(alternatives: alternatives, isUppercase: isUppercase)
        case .changed:
            guard let host = popupHostView else { break }
            let locationInHost = gesture.location(in: host)
            if isExpanded {
                updatePopupHighlight(for: locationInHost)
            }
        case .ended:
            expansionWorkItem?.cancel()
            if isExpanded {
                selectAndInsert()
            } else if let baseCharacter = self.baseCharacter {
                onCharacterSelected?(baseCharacter)
            }
            cleanupPopup()
        case .cancelled, .failed:
            expansionWorkItem?.cancel()
            cleanupPopup()
        default:
            break
        }
    }
    
    private func showInitialPopup(from keyView: KeyView) {
        guard let host = hostView(for: keyView) else { return }
        cleanupPopup()
        currentCharacters = [baseCharacter ?? keyView.key.displayText(isUppercase: true)]
        let fallbackTokens = ThemeManager.tokens(for: .system, colorScheme: .light)
        let popupPalette = self.palette ?? ThemeBridge.palette(for: fallbackTokens)
        let popup = PopupKeyView(alternatives: currentCharacters, palette: popupPalette)
        popup.delegate = self
        popup.translatesAutoresizingMaskIntoConstraints = true
        popup.isUserInteractionEnabled = false
        
        let keyFrame = keyView.convert(keyView.bounds, to: host)
        currentAnchorFrame = keyFrame
        let size = popup.preferredSize(maxWidth: host.bounds.width - 20)
        let originX = min(max(8, keyFrame.midX - size.width / 2), host.bounds.width - size.width - 8)
        let originY = max(4, keyFrame.minY - size.height + 6)
        popup.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
        
        host.addSubview(popup)
        popupView = popup
        popup.animateAppearance()
    }
    
    private func scheduleExpansion(alternatives: AlternativeCharactersProvider.Alternatives?, isUppercase: Bool) {
        expansionWorkItem?.cancel()
        guard let alternatives = alternatives else { return }
        let workItem = DispatchWorkItem { [weak self] in
            self?.expandPopup(with: alternatives, isUppercase: isUppercase)
        }
        expansionWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + popupDelay, execute: workItem)
    }
    
    private func expandPopup(with alternatives: AlternativeCharactersProvider.Alternatives, isUppercase: Bool) {
        guard let popupView, let baseCharacter, let host = popupHostView else { return }
        isExpanded = true
        if isUppercase {
            currentCharacters = [baseCharacter] + alternatives.uppercase
        } else {
            currentCharacters = [baseCharacter] + alternatives.lowercase
        }
        popupView.updateCharacters(currentCharacters)
        
        let newSize = popupView.preferredSize(maxWidth: host.bounds.width - 20)
        var frame = popupView.frame
        frame.size = newSize
        frame.origin.y = max(4, currentAnchorFrame.minY - newSize.height + 6)
        frame.origin.x = min(max(8, currentAnchorFrame.midX - newSize.width / 2), host.bounds.width - newSize.width - 8)
        popupView.frame = frame
        popupView.updateHighlight(for: CGPoint(x: popupView.bounds.midX, y: popupView.bounds.midY))
    }
    
    private func updatePopupHighlight(for location: CGPoint) {
        guard let popupView else { return }
        popupView.updateHighlight(for: location)
    }
    
    private func selectAndInsert() {
        guard let popupView else { return }
        popupView.selectHighlightedCharacter()
    }
    
    private func cleanupPopup() {
        expansionWorkItem?.cancel()
        let viewToRemove = popupView
        popupView = nil
        viewToRemove?.animateDismissal {
            viewToRemove?.removeFromSuperview()
        }
        panGesture = nil
        isExpanded = false
        lastHighlightedCharacter = nil
    }
    
    private func hostView(for keyView: UIView) -> UIView? {
        if let window = keyView.window ?? containerView?.window {
            if popupHostView == nil {
                let host = UIView(frame: window.bounds)
                host.isUserInteractionEnabled = false
                host.backgroundColor = .clear
                host.translatesAutoresizingMaskIntoConstraints = false
                window.addSubview(host)
                NSLayoutConstraint.activate([
                    host.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    host.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                    host.topAnchor.constraint(equalTo: window.topAnchor),
                    host.bottomAnchor.constraint(equalTo: window.bottomAnchor)
                ])
                popupHostView = host
            }
            return popupHostView
        }
        return containerView
    }
}

// MARK: - PopupKeyViewDelegate

extension LongPressHandler {
    func popupKeyView(_ view: PopupKeyView, didSelect character: String) {
        onCharacterSelected?(character)
        cleanupPopup()
    }
    
    func popupKeyView(_ view: PopupKeyView, highlightedCharacter: String?) {
        if let character = highlightedCharacter, character != lastHighlightedCharacter {
            lastHighlightedCharacter = character
            haptics?.playSelectionChanged()
        } else if highlightedCharacter == nil {
            lastHighlightedCharacter = nil
        }
    }
}
