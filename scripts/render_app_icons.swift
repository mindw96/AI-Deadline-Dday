#!/usr/bin/env swift

import AppKit
import Foundation
import UniformTypeIdentifiers

guard CommandLine.arguments.count == 5 else {
    fputs("Usage: render_app_icons.swift <source-png> <mac-png> <ios-png> <iconset-dir>\n", stderr)
    exit(64)
}

let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let macPNGURL = URL(fileURLWithPath: CommandLine.arguments[2])
let iosPNGURL = URL(fileURLWithPath: CommandLine.arguments[3])
let iconsetURL = URL(fileURLWithPath: CommandLine.arguments[4])

guard
    let sourceImage = NSImage(contentsOf: sourceURL),
    let tiff = sourceImage.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff)
else {
    fputs("Could not load source icon: \(sourceURL.path)\n", stderr)
    exit(66)
}

let pixelWidth = bitmap.pixelsWide
let pixelHeight = bitmap.pixelsHigh
var minX = pixelWidth
var minY = pixelHeight
var maxX = 0
var maxY = 0

for y in 0..<pixelHeight {
    for x in 0..<pixelWidth {
        guard let color = bitmap.colorAt(x: x, y: y), color.alphaComponent > 0.02 else {
            continue
        }

        minX = min(minX, x)
        minY = min(minY, y)
        maxX = max(maxX, x)
        maxY = max(maxY, y)
    }
}

let cropRect: NSRect
if minX <= maxX && minY <= maxY {
    let width = CGFloat(maxX - minX + 1)
    let height = CGFloat(maxY - minY + 1)
    let padding = max(width, height) * 0.015
    cropRect = NSRect(
        x: max(0, CGFloat(minX) - padding),
        y: max(0, CGFloat(pixelHeight - maxY - 1) - padding),
        width: min(CGFloat(pixelWidth), width + padding * 2),
        height: min(CGFloat(pixelHeight), height + padding * 2)
    )
} else {
    cropRect = NSRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight)
}

func drawSource(in rect: NSRect) {
    sourceImage.draw(
        in: rect,
        from: cropRect,
        operation: .sourceOver,
        fraction: 1,
        respectFlipped: false,
        hints: [.interpolation: NSImageInterpolation.high]
    )
}

func makeImage(size: Int, opaque: Bool) throws -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let alphaInfo: CGImageAlphaInfo = opaque ? .noneSkipLast : .premultipliedLast
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: size * 4,
        space: colorSpace,
        bitmapInfo: alphaInfo.rawValue
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    NSGraphicsContext.saveGraphicsState()
    let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
    NSGraphicsContext.current = graphicsContext
    graphicsContext.imageInterpolation = .high

    let rect = NSRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size))

    if opaque {
        let gradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.34, green: 0.25, blue: 0.95, alpha: 1),
            NSColor(calibratedRed: 0.09, green: 0.57, blue: 0.96, alpha: 1)
        ])!
        gradient.draw(in: rect, angle: 0)
    } else {
        NSColor.clear.setFill()
        rect.fill()
    }

    drawSource(in: rect)

    NSGraphicsContext.restoreGraphicsState()
    guard let image = context.makeImage() else {
        throw CocoaError(.fileWriteUnknown)
    }
    return image
}

func writePNG(_ image: CGImage, to url: URL) throws {
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )

    guard
        let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
        )
    else {
        throw CocoaError(.fileWriteUnknown)
    }

    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw CocoaError(.fileWriteUnknown)
    }
}

try? FileManager.default.removeItem(at: iconsetURL)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let iconSizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

let macImage = try makeImage(size: 1024, opaque: false)
try writePNG(macImage, to: macPNGURL)

let iosImage = try makeImage(size: 1024, opaque: true)
try writePNG(iosImage, to: iosPNGURL)

for (filename, size) in iconSizes {
    try writePNG(
        try makeImage(size: Int(size), opaque: false),
        to: iconsetURL.appendingPathComponent(filename)
    )
}
