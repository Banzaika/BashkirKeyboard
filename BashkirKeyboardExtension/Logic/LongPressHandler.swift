import UIKit
import SwiftUI

final class LongPressHandler: PopupKeyViewDelegate {
    weak var containerView: UIView?
    var onCharacterSelected: ((String) -> Void)?
    var haptics: HapticFeedbackManager?
    private var popupView: PopupKeyView?
    private var palette: UIKitThemePalette?
    private weak var sourceKeyView: KeyView?
    private var gestureRecognizer: UILongPressGestureRecognizer?
    
    // Touch tracking for sliding selection
    private var panGesture: UIPanGestureRecognizer?
    private var lastHighlightedCharacter: String?
    
    func handle(gesture: UILongPressGestureRecognizer,
                keyView: KeyView,
                alternatives: [String],
                palette: UIKitThemePalette) {
        guard !alternatives.isEmpty else { return }
        self.palette = palette
        self.sourceKeyView = keyView
        self.gestureRecognizer = gesture
        
        switch gesture.state {
        case .began:
            showPopup(from: keyView, alternatives: alternatives)
            setupPanGesture(for: keyView)
        case .changed:
            // Handle sliding selection - touch moved while finger is down
            guard let containerView = containerView else { break }
            let location = gesture.location(in: containerView)
            updatePopupHighlight(for: location)
        case .ended:
            // Finger lifted - insert selected character
            selectAndInsert()
            removePopup()
        case .cancelled, .failed:
            removePopup()
        default:
            break
        }
    }
    
    private func showPopup(from keyView: KeyView, alternatives: [String]) {
        guard let containerView else { return }
        removePopup()
        
        let fallbackTokens = ThemeManager.tokens(for: .system, colorScheme: .light)
        let popupPalette = self.palette ?? ThemeBridge.palette(for: fallbackTokens)
        let popup = PopupKeyView(alternatives: alternatives, palette: popupPalette)
        popup.delegate = self
        popup.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(popup)
        
        // Calculate popup size based on number of alternatives
        let minWidth: CGFloat = 60
        let maxWidth: CGFloat = 400
        let widthPerChar: CGFloat = 45
        let popupWidth = min(maxWidth, max(minWidth, CGFloat(alternatives.count) * widthPerChar + 16))
        let popupHeight: CGFloat = 50
        
        NSLayoutConstraint.activate([
            popup.widthAnchor.constraint(equalToConstant: popupWidth),
            popup.heightAnchor.constraint(equalToConstant: popupHeight + 12), // +12 for arrow
            popup.bottomAnchor.constraint(equalTo: keyView.topAnchor, constant: -4),
            popup.centerXAnchor.constraint(equalTo: keyView.centerXAnchor)
        ])
        
        popupView = popup
        popup.animateAppearance()
        
        // Set initial highlight to first character after layout
        popup.setNeedsLayout()
        popup.layoutIfNeeded()
        
        DispatchQueue.main.async { [weak popup] in
            guard let popup = popup else { return }
            // Highlight first character by default
            if popup.bounds.width > 0 {
                let initialLocation = CGPoint(x: popup.bounds.midX, y: popup.bounds.midY)
                popup.updateHighlight(for: initialLocation)
            }
        }
    }
    
    private func setupPanGesture(for keyView: KeyView) {
        // Remove existing pan gesture if any
        if let existingPan = panGesture {
            existingPan.view?.removeGestureRecognizer(existingPan)
        }
        
        // The long press gesture already tracks movement via .changed state
        // No need for separate pan gesture - UILongPressGestureRecognizer handles it
    }
    
    private func updatePopupHighlight(for location: CGPoint) {
        guard let popupView else { return }
        popupView.updateHighlight(for: location)
    }
    
    private func selectAndInsert() {
        guard let popupView else { return }
        popupView.selectHighlightedCharacter()
    }
    
    private func removePopup() {
        if let popupView = popupView {
            popupView.animateDismissal {
                popupView.removeFromSuperview()
            }
        }
        popupView = nil
        panGesture = nil
    }
    
    // MARK: - PopupKeyViewDelegate
    
    func popupKeyView(_ view: PopupKeyView, didSelect character: String) {
        onCharacterSelected?(character)
        removePopup()
    }
    
    func popupKeyView(_ view: PopupKeyView, highlightedCharacter: String?) {
        // Provide haptic feedback when sliding between characters
        if let character = highlightedCharacter, character != lastHighlightedCharacter {
            lastHighlightedCharacter = character
            haptics?.playSelectionChanged()
        } else if highlightedCharacter == nil {
            lastHighlightedCharacter = nil
        }
    }
}
