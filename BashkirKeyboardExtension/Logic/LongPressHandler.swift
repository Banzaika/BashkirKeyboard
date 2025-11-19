import UIKit
import SwiftUI

final class LongPressHandler: PopupKeyViewDelegate {
    weak var containerView: UIView?
    var onCharacterSelected: ((String) -> Void)?
    private var popupView: PopupKeyView?
    private var palette: UIKitThemePalette?

    func handle(gesture: UILongPressGestureRecognizer,
                keyView: KeyView,
                alternatives: [String],
                palette: UIKitThemePalette) {
        guard !alternatives.isEmpty else { return }
        self.palette = palette

        switch gesture.state {
        case .began:
            showPopup(from: keyView, alternatives: alternatives)
        case .ended, .cancelled, .failed:
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

        NSLayoutConstraint.activate([
            popup.bottomAnchor.constraint(equalTo: keyView.topAnchor, constant: -8),
            popup.centerXAnchor.constraint(equalTo: keyView.centerXAnchor)
        ])

        popup.alpha = 0
        UIView.animate(withDuration: 0.15) {
            popup.alpha = 1
        }
        popupView = popup
    }

    private func removePopup() {
        popupView?.removeFromSuperview()
        popupView = nil
    }

    func popupKeyView(_ view: PopupKeyView, didSelect character: String) {
        onCharacterSelected?(character)
        removePopup()
    }
}
