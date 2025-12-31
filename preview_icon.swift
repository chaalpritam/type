#!/usr/bin/env swift
import AppKit
import Foundation

// Create a large preview version of the icon (1024x1024)
func generateIcon(size: CGSize, scale: CGFloat) -> NSImage {
    let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
    let image = NSImage(size: pixelSize)
    
    image.lockFocus()
    
    let rect = CGRect(origin: .zero, size: pixelSize)
    
    // Background gradient
    let gradient = NSGradient(colors: [
        NSColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0),
        NSColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
    ])
    gradient?.draw(in: rect, angle: 135)
    
    let cornerRadius = pixelSize.width * 0.15
    let roundedPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    roundedPath.addClip()
    
    // Paper texture lines
    NSColor(white: 0.0, alpha: 0.03).setStroke()
    let lineSpacing = pixelSize.height / 20
    for i in 1..<20 {
        let y = CGFloat(i) * lineSpacing
        let linePath = NSBezierPath()
        linePath.move(to: CGPoint(x: pixelSize.width * 0.15, y: y))
        linePath.line(to: CGPoint(x: pixelSize.width * 0.85, y: y))
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
    
    let fontSize = pixelSize.width * 0.12
    let titleFontSize = pixelSize.width * 0.08
    
    // "FADE IN:" text
    let fadeInText = "FADE IN:"
    let fadeInAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: titleFontSize, weight: .bold),
        .foregroundColor: NSColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0)
    ]
    let fadeInString = NSAttributedString(string: fadeInText, attributes: fadeInAttrs)
    let fadeInRect = CGRect(
        x: pixelSize.width * 0.15,
        y: pixelSize.height * 0.70,
        width: pixelSize.width * 0.7,
        height: titleFontSize * 1.5
    )
    fadeInString.draw(in: fadeInRect)
    
    // Screenplay lines
    let textAttrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: fontSize * 0.7, weight: .regular),
        .foregroundColor: NSColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 0.8)
    ]
    
    let lines = [
        "INT. OFFICE - DAY",
        "",
        "A writer sits at their desk,",
        "crafting the perfect scene."
    ]
    
    var yPosition = pixelSize.height * 0.55
    for line in lines {
        let attrString = NSAttributedString(string: line, attributes: textAttrs)
        let lineRect = CGRect(
            x: pixelSize.width * 0.15,
            y: yPosition,
            width: pixelSize.width * 0.7,
            height: fontSize
        )
        attrString.draw(in: lineRect)
        yPosition -= fontSize * 1.3
    }
    
    // Clapperboard
    let clapperSize = pixelSize.width * 0.2
    let clapperRect = CGRect(
        x: pixelSize.width * 0.4,
        y: pixelSize.height * 0.12,
        width: clapperSize,
        height: clapperSize * 0.8
    )
    
    NSColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1.0).setFill()
    let bodyPath = NSBezierPath(roundedRect: clapperRect, xRadius: 2, yRadius: 2)
    bodyPath.fill()
    
    let topRect = CGRect(
        x: clapperRect.minX,
        y: clapperRect.maxY - clapperSize * 0.25,
        width: clapperRect.width,
        height: clapperSize * 0.25
    )
    
    let stripeWidth = topRect.width / 5
    for i in 0..<5 {
        let color = i % 2 == 0 ? NSColor.white : NSColor.black
        color.setFill()
        let stripeRect = CGRect(
            x: topRect.minX + CGFloat(i) * stripeWidth,
            y: topRect.minY,
            width: stripeWidth,
            height: topRect.height
        )
        NSBezierPath(rect: stripeRect).fill()
    }
    
    let shadowPath = NSBezierPath(roundedRect: clapperRect.offsetBy(dx: 1, dy: -1), xRadius: 2, yRadius: 2)
    NSColor(white: 0.0, alpha: 0.15).setFill()
    shadowPath.fill()
    
    image.unlockFocus()
    return image
}

let size = CGSize(width: 1024, height: 1024)
let image = generateIcon(size: size, scale: 1.0)

if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    try pngData.write(to: URL(fileURLWithPath: "app_icon_preview.png"))
    print("✓ Created app_icon_preview.png (1024x1024)")
}
