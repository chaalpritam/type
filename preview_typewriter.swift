#!/usr/bin/env swift
import AppKit
import Foundation

func generateIcon(size: CGSize, scale: CGFloat) -> NSImage {
    let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
    let image = NSImage(size: pixelSize)
    
    image.lockFocus()
    
    let rect = CGRect(origin: .zero, size: pixelSize)
    
    NSColor.white.setFill()
    NSBezierPath(rect: rect).fill()
    
    let cornerRadius = pixelSize.width * 0.18
    let roundedPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    roundedPath.addClip()
    
    let typewriterScale = pixelSize.width * 0.5
    let centerX = pixelSize.width * 0.5
    let centerY = pixelSize.height * 0.48
    
    let typewriterColor = NSColor.black
    
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
    
    typewriterColor.setStroke()
    let paperOutline = NSBezierPath(roundedRect: paperRect, xRadius: pixelSize.width * 0.01, yRadius: pixelSize.width * 0.01)
    paperOutline.lineWidth = pixelSize.width * 0.006
    paperOutline.stroke()
    
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
    
    let keyboardY = bodyRect.minY + bodyHeight * 0.25
    let keySize = pixelSize.width * 0.025
    let keySpacing = keySize * 1.4
    let keysPerRow = 7
    
    for row in 0..<3 {
        let rowY = keyboardY + CGFloat(row) * keySpacing
        let rowOffset = CGFloat(row) * keySize * 0.3
        
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
    
    for i in 0..<8 {
        let lineX = rollerRect.minX + (rollerRect.width / 8) * CGFloat(i)
        let linePath = NSBezierPath()
        linePath.move(to: CGPoint(x: lineX, y: rollerRect.minY))
        linePath.line(to: CGPoint(x: lineX, y: rollerRect.maxY))
        linePath.lineWidth = pixelSize.width * 0.003
        NSColor.white.setStroke()
        linePath.stroke()
    }
    
    let footWidth = bodyWidth * 0.12
    let footHeight = bodyHeight * 0.15
    
    let leftFootRect = CGRect(
        x: bodyRect.minX + bodyWidth * 0.1,
        y: bodyRect.minY - footHeight,
        width: footWidth,
        height: footHeight
    )
    typewriterColor.setFill()
    NSBezierPath(roundedRect: leftFootRect, xRadius: pixelSize.width * 0.01, yRadius: pixelSize.width * 0.01).fill()
    
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

let size = CGSize(width: 1024, height: 1024)
let image = generateIcon(size: size, scale: 1.0)

if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    try pngData.write(to: URL(fileURLWithPath: "app_icon_preview.png"))
    print("✓ Created app_icon_preview.png (1024x1024)")
}
