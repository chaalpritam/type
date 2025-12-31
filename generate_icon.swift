#!/usr/bin/env swift

import AppKit
import Foundation

// Icon Generator for Screenplay App
// Creates a minimalist typewriter icon in black on white background

func generateIcon(size: CGSize, scale: CGFloat) -> NSImage {
    let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
    let image = NSImage(size: pixelSize)

    image.lockFocus()

    let rect = CGRect(origin: .zero, size: pixelSize)

    // White background
    NSColor.white.setFill()
    NSBezierPath(rect: rect).fill()

    // Add rounded corners for modern macOS look
    let cornerRadius = pixelSize.width * 0.18
    let roundedPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    roundedPath.addClip()

    // Draw typewriter
    let typewriterScale = pixelSize.width * 0.5
    let centerX = pixelSize.width * 0.5
    let centerY = pixelSize.height * 0.48

    // Typewriter color - pure black
    let typewriterColor = NSColor.black

    // Draw typewriter body (main rectangle)
    let bodyWidth = typewriterScale * 0.9
    let bodyHeight = typewriterScale * 0.35
    let bodyRect = CGRect(
        x: centerX - bodyWidth / 2,
        y: centerY - bodyHeight / 2,
        width: bodyWidth,
        height: bodyHeight
    )

    typewriterColor.setFill()
    let bodyPath = NSBezierPath(roundedRect: bodyRect, xRadius: pixelSize.width * 0.02, yRadius: pixelSize.width * 0.02)
    bodyPath.fill()

    // Draw paper (white sheet coming out of top)
    let paperWidth = bodyWidth * 0.5
    let paperHeight = bodyHeight * 0.9
    let paperRect = CGRect(
        x: centerX - paperWidth / 2,
        y: bodyRect.maxY - paperHeight * 0.3,
        width: paperWidth,
        height: paperHeight
    )

    NSColor.white.setFill()
    NSBezierPath(roundedRect: paperRect, xRadius: pixelSize.width * 0.01, yRadius: pixelSize.width * 0.01).fill()

    // Paper outline
    typewriterColor.setStroke()
    let paperOutline = NSBezierPath(roundedRect: paperRect, xRadius: pixelSize.width * 0.01, yRadius: pixelSize.width * 0.01)
    paperOutline.lineWidth = pixelSize.width * 0.006
    paperOutline.stroke()

    // Paper lines (text on paper)
    let lineCount = 5
    let lineSpacing = paperHeight * 0.15
    let lineY = paperRect.minY + paperHeight * 0.25

    for i in 0..<lineCount {
        let y = lineY + CGFloat(i) * lineSpacing
        let linePath = NSBezierPath()
        linePath.move(to: CGPoint(x: paperRect.minX + paperWidth * 0.15, y: y))
        linePath.line(to: CGPoint(x: paperRect.maxX - paperWidth * 0.15, y: y))
        linePath.lineWidth = pixelSize.width * 0.004
        typewriterColor.setStroke()
        linePath.stroke()
    }

    // Draw keyboard area (keys)
    let keyboardY = bodyRect.minY + bodyHeight * 0.25
    let keySize = pixelSize.width * 0.025
    let keySpacing = keySize * 1.4
    let keysPerRow = 7

    for row in 0..<3 {
        let rowY = keyboardY + CGFloat(row) * keySpacing
        let rowOffset = CGFloat(row) * keySize * 0.3 // Offset for staggered keys

        for col in 0..<keysPerRow {
            let keyX = centerX - (CGFloat(keysPerRow) * keySpacing) / 2 + CGFloat(col) * keySpacing + rowOffset
            let keyRect = CGRect(x: keyX, y: rowY, width: keySize, height: keySize)

            NSColor.white.setFill()
            NSBezierPath(roundedRect: keyRect, xRadius: keySize * 0.15, yRadius: keySize * 0.15).fill()

            typewriterColor.setStroke()
            let keyOutline = NSBezierPath(roundedRect: keyRect, xRadius: keySize * 0.15, yRadius: keySize * 0.15)
            keyOutline.lineWidth = pixelSize.width * 0.003
            keyOutline.stroke()
        }
    }

    // Draw carriage return lever (iconic typewriter element)
    let leverStartX = bodyRect.maxX - bodyWidth * 0.15
    let leverStartY = bodyRect.maxY - bodyHeight * 0.2
    let leverEndX = leverStartX + bodyWidth * 0.12
    let leverEndY = leverStartY + bodyHeight * 0.4

    let leverPath = NSBezierPath()
    leverPath.move(to: CGPoint(x: leverStartX, y: leverStartY))
    leverPath.line(to: CGPoint(x: leverEndX, y: leverEndY))
    leverPath.lineWidth = pixelSize.width * 0.012
    leverPath.lineCapStyle = .round
    typewriterColor.setStroke()
    leverPath.stroke()

    // Lever knob
    let knobRadius = pixelSize.width * 0.018
    let knobPath = NSBezierPath(
        ovalIn: CGRect(
            x: leverEndX - knobRadius,
            y: leverEndY - knobRadius,
            width: knobRadius * 2,
            height: knobRadius * 2
        )
    )
    typewriterColor.setFill()
    knobPath.fill()

    // Draw roller (paper roller at top)
    let rollerWidth = paperWidth * 1.1
    let rollerHeight = bodyHeight * 0.18
    let rollerRect = CGRect(
        x: centerX - rollerWidth / 2,
        y: bodyRect.maxY - rollerHeight / 2,
        width: rollerWidth,
        height: rollerHeight
    )

    typewriterColor.setFill()
    NSBezierPath(ovalIn: rollerRect).fill()

    // Roller details (lines)
    for i in 0..<8 {
        let lineX = rollerRect.minX + (rollerRect.width / 8) * CGFloat(i)
        let linePath = NSBezierPath()
        linePath.move(to: CGPoint(x: lineX, y: rollerRect.minY))
        linePath.line(to: CGPoint(x: lineX, y: rollerRect.maxY))
        linePath.lineWidth = pixelSize.width * 0.003
        NSColor.white.setStroke()
        linePath.stroke()
    }

    // Base/feet of typewriter
    let footWidth = bodyWidth * 0.12
    let footHeight = bodyHeight * 0.15

    // Left foot
    let leftFootRect = CGRect(
        x: bodyRect.minX + bodyWidth * 0.1,
        y: bodyRect.minY - footHeight,
        width: footWidth,
        height: footHeight
    )
    typewriterColor.setFill()
    NSBezierPath(roundedRect: leftFootRect, xRadius: pixelSize.width * 0.01, yRadius: pixelSize.width * 0.01).fill()

    // Right foot
    let rightFootRect = CGRect(
        x: bodyRect.maxX - bodyWidth * 0.1 - footWidth,
        y: bodyRect.minY - footHeight,
        width: footWidth,
        height: footHeight
    )
    NSBezierPath(roundedRect: rightFootRect, xRadius: pixelSize.width * 0.01, yRadius: pixelSize.width * 0.01).fill()

    image.unlockFocus()

    return image
}

func saveIcon(image: NSImage, path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("✓ Generated: \(path)")
    } catch {
        print("✗ Failed to write: \(path) - \(error)")
    }
}

// Main execution
let iconSizes: [(size: CGFloat, scales: [CGFloat])] = [
    (16, [1, 2]),
    (32, [1, 2]),
    (128, [1, 2]),
    (256, [1, 2]),
    (512, [1, 2])
]

let outputDir = "type/Assets.xcassets/AppIcon.appiconset"

print("Generating typewriter app icons...")
print("Output directory: \(outputDir)")
print("")

for (size, scales) in iconSizes {
    for scale in scales {
        let iconSize = CGSize(width: size, height: size)
        let image = generateIcon(size: iconSize, scale: scale)

        let filename = "icon_\(Int(size))x\(Int(size))@\(Int(scale))x.png"
        let path = "\(outputDir)/\(filename)"

        saveIcon(image: image, path: path)
    }
}

print("")
print("Icon generation complete!")
print("Now updating Contents.json...")

// Update Contents.json
let contentsJSON = """
{
  "images" : [
    {
      "filename" : "icon_16x16@1x.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_16x16@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32x32@1x.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_32x32@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128x128@1x.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_128x128@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256x256@1x.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_256x256@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512x512@1x.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_512x512@2x.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""

do {
    try contentsJSON.write(toFile: "\(outputDir)/Contents.json", atomically: true, encoding: .utf8)
    print("✓ Updated Contents.json")
} catch {
    print("✗ Failed to update Contents.json: \(error)")
}

print("")
print("All done! Your app now has a minimalist typewriter icon.")
