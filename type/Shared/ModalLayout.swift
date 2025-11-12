import SwiftUI

/// Common layout helpers for sheet-style modals to ensure consistent spacing and alignment.
struct ModalContainerStyle: ViewModifier {
    var maxWidth: CGFloat
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var alignment: Alignment
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: maxWidth, alignment: alignment)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct ModalSectionStyle: ViewModifier {
    var backgroundColor: Color
    var cornerRadius: CGFloat
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    /// Applies a consistent modal container width and padding so modal content aligns properly.
    func modalContainer(
        maxWidth: CGFloat = 680,
        horizontalPadding: CGFloat = 24,
        verticalPadding: CGFloat = 24,
        alignment: Alignment = .topLeading
    ) -> some View {
        modifier(
            ModalContainerStyle(
                maxWidth: maxWidth,
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                alignment: alignment
            )
        )
    }
    
    /// Applies a consistent card style for sections inside modal sheets.
    func modalSectionStyle(
        backgroundColor: Color = Color(NSColor.controlBackgroundColor),
        cornerRadius: CGFloat = 12,
        padding: CGFloat = 16
    ) -> some View {
        modifier(
            ModalSectionStyle(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                padding: padding
            )
        )
    }
}

