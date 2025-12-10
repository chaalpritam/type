import SwiftUI

/// Common layout helpers for sheet-style modals to ensure consistent spacing and alignment.
struct ModalContainerStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
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
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(colorScheme == .dark ? TypeColors.sidebarBackgroundDark : TypeColors.sidebarBackgroundLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
            )
    }
}

extension View {
    /// Applies a consistent modal container width and padding so modal content aligns properly.
    func modalContainer(
        maxWidth: CGFloat = 680,
        horizontalPadding: CGFloat = TypeSpacing.lg,
        verticalPadding: CGFloat = TypeSpacing.lg,
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
        cornerRadius: CGFloat = TypeRadius.md,
        padding: CGFloat = TypeSpacing.md
    ) -> some View {
        modifier(
            ModalSectionStyle(
                cornerRadius: cornerRadius,
                padding: padding
            )
        )
    }
}

// MARK: - Type Modal Components

/// Type-styled text field for modals
struct TypeTextField: View {
    @Environment(\.colorScheme) var colorScheme
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int>? = nil
    
    var body: some View {
        TextField(placeholder, text: $text, axis: axis)
            .textFieldStyle(.plain)
            .font(TypeTypography.body)
            .padding(TypeSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: TypeRadius.sm)
                    .stroke(colorScheme == .dark ? TypeColors.dividerDark : TypeColors.dividerLight, lineWidth: 0.5)
            )
    }
}

/// Type-styled section header for modals
struct TypeModalSectionHeader: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: TypeSpacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(TypeColors.accent)
            }
            
            Text(title)
                .font(TypeTypography.subheadline)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
        }
    }
}

/// Type-styled picker for modals
struct TypeModalPicker<T: Hashable>: View {
    @Environment(\.colorScheme) var colorScheme
    let title: String
    @Binding var selection: T
    let options: [(String, T)]
    
    var body: some View {
        HStack {
            Text(title)
                .font(TypeTypography.body)
                .foregroundColor(colorScheme == .dark ? TypeColors.primaryTextDark : TypeColors.primaryTextLight)
            
            Spacer()
            
            Menu {
                ForEach(options, id: \.1) { option in
                    Button(option.0) { selection = option.1 }
                }
            } label: {
                HStack(spacing: TypeSpacing.xs) {
                    Text(currentLabel)
                        .font(TypeTypography.body)
                        .foregroundColor(colorScheme == .dark ? TypeColors.secondaryTextDark : TypeColors.secondaryTextLight)
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundColor(colorScheme == .dark ? TypeColors.tertiaryTextDark : TypeColors.tertiaryTextLight)
                }
                .padding(.horizontal, TypeSpacing.sm)
                .padding(.vertical, TypeSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: TypeRadius.sm)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var currentLabel: String {
        options.first { $0.1 == selection }?.0 ?? ""
    }
}

/// Type-styled tag pill
struct TypeTagPill: View {
    let text: String
    let color: Color
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(TypeTypography.caption)
                .foregroundColor(color)
            
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(color.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, TypeSpacing.sm)
        .padding(.vertical, TypeSpacing.xxs)
        .background(color.opacity(0.12))
        .cornerRadius(TypeRadius.full)
    }
}

/// Type-styled modal button
struct TypeModalButton: View {
    let title: String
    var style: ButtonStyle = .primary
    var isDisabled: Bool = false
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(TypeTypography.body)
                .fontWeight(.medium)
                .foregroundColor(foregroundColor)
                .padding(.horizontal, TypeSpacing.lg)
                .padding(.vertical, TypeSpacing.sm)
                .background(backgroundColor)
                .cornerRadius(TypeRadius.sm)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return TypeColors.accent
        case .secondary: return Color.clear
        case .destructive: return TypeColors.error
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return TypeColors.accent
        }
    }
}
