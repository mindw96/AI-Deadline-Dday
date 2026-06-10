#!/usr/bin/env swift

import AppKit
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: generate_dmg_background.swift <output-png>\n", stderr)
    exit(64)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let canvas = NSSize(width: 760, height: 480)
let image = NSImage(size: canvas)

func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> NSRect {
    NSRect(x: x, y: y, width: width, height: height)
}

func drawText(_ text: String, in target: NSRect, font: NSFont, color: NSColor, alignment: NSTextAlignment = .center) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byTruncatingTail
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]
    text.draw(in: target, withAttributes: attributes)
}

image.lockFocus()

NSColor(calibratedWhite: 0.965, alpha: 1).setFill()
NSBezierPath(rect: rect(0, 0, canvas.width, canvas.height)).fill()

let topGradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.36, green: 0.25, blue: 0.98, alpha: 1),
    NSColor(calibratedRed: 0.10, green: 0.58, blue: 0.98, alpha: 1)
])!
let topPath = NSBezierPath(roundedRect: rect(32, 18, 696, 420), xRadius: 34, yRadius: 34)
topGradient.draw(in: topPath, angle: 0)

NSColor(calibratedWhite: 1, alpha: 0.17).setFill()
NSBezierPath(roundedRect: rect(74, 58, 612, 336), xRadius: 28, yRadius: 28).fill()

NSColor(calibratedWhite: 1, alpha: 0.92).setFill()
NSBezierPath(roundedRect: rect(86, 74, 588, 308), xRadius: 24, yRadius: 24).fill()

let blue = NSColor(calibratedRed: 0.10, green: 0.43, blue: 0.95, alpha: 1)
let purple = NSColor(calibratedRed: 0.34, green: 0.25, blue: 0.92, alpha: 1)

drawText(
    "Dday",
    in: rect(0, 330, canvas.width, 56),
    font: .systemFont(ofSize: 34, weight: .bold),
    color: NSColor(calibratedWhite: 0.08, alpha: 1)
)
drawText(
    "Drag Dday to Applications",
    in: rect(0, 298, canvas.width, 28),
    font: .systemFont(ofSize: 18, weight: .semibold),
    color: NSColor(calibratedWhite: 0.22, alpha: 1)
)
drawText(
    "AI conference deadlines, one glance away.",
    in: rect(0, 91, canvas.width, 24),
    font: .systemFont(ofSize: 14, weight: .medium),
    color: NSColor(calibratedWhite: 0.42, alpha: 1)
)

let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 300, y: 248))
arrow.line(to: NSPoint(x: 460, y: 248))
arrow.lineWidth = 5
arrow.lineCapStyle = .round
blue.withAlphaComponent(0.72).setStroke()
arrow.stroke()

let head = NSBezierPath()
head.move(to: NSPoint(x: 460, y: 248))
head.line(to: NSPoint(x: 438, y: 263))
head.move(to: NSPoint(x: 460, y: 248))
head.line(to: NSPoint(x: 438, y: 233))
head.lineWidth = 5
head.lineCapStyle = .round
blue.withAlphaComponent(0.72).setStroke()
head.stroke()

let leftCircle = NSBezierPath(ovalIn: rect(132, 204, 126, 126))
NSColor(calibratedWhite: 1, alpha: 0.86).setFill()
leftCircle.fill()
purple.withAlphaComponent(0.12).setStroke()
leftCircle.lineWidth = 2
leftCircle.stroke()

let rightCircle = NSBezierPath(ovalIn: rect(502, 204, 126, 126))
NSColor(calibratedWhite: 1, alpha: 0.86).setFill()
rightCircle.fill()
blue.withAlphaComponent(0.12).setStroke()
rightCircle.lineWidth = 2
rightCircle.stroke()

drawText(
    "1",
    in: rect(132, 231, 126, 54),
    font: .systemFont(ofSize: 46, weight: .heavy),
    color: purple.withAlphaComponent(0.24)
)
drawText(
    "2",
    in: rect(502, 231, 126, 54),
    font: .systemFont(ofSize: 46, weight: .heavy),
    color: blue.withAlphaComponent(0.24)
)

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fputs("Failed to render background image\n", stderr)
    exit(70)
}

try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try png.write(to: outputURL)
