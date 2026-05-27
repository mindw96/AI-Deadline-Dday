import AppKit
import DdayCore

struct StatusBadgeRenderer {
    private let font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
    private let horizontalPadding: CGFloat = 9
    private let imageHeight: CGFloat = 22
    private let badgeHeight: CGFloat = 20
    private let cornerRadius: CGFloat = 5

    func image(for text: String, style: MenuBarVisualStyle) -> NSImage {
        let attributes = textAttributes(for: style)
        let textSize = text.size(withAttributes: attributes)
        let imageWidth = ceil(textSize.width + horizontalPadding * 2)
        let image = NSImage(size: NSSize(width: imageWidth, height: imageHeight))

        image.lockFocus()
        defer { image.unlockFocus() }

        let badgeRect = NSRect(
            x: 0,
            y: (imageHeight - badgeHeight) / 2,
            width: imageWidth,
            height: badgeHeight
        )
        let path = NSBezierPath(roundedRect: badgeRect, xRadius: cornerRadius, yRadius: cornerRadius)
        backgroundColor(for: style).setFill()
        path.fill()

        let textRect = NSRect(
            x: horizontalPadding,
            y: floor((imageHeight - textSize.height) / 2) + 1,
            width: textSize.width,
            height: textSize.height
        )

        text.draw(in: textRect, withAttributes: attributes)

        return image
    }

    private func textAttributes(for style: MenuBarVisualStyle) -> [NSAttributedString.Key: Any] {
        let color: NSColor = style == .badge
            ? NSColor(calibratedWhite: 0.34, alpha: 1)
            : .black

        return [
            .font: font,
            .foregroundColor: color,
            .kern: 0
        ]
    }

    private func backgroundColor(for style: MenuBarVisualStyle) -> NSColor {
        switch style {
        case .plain:
            return .clear
        case .badge:
            return NSColor(calibratedWhite: 0.93, alpha: 0.96)
        }
    }
}
