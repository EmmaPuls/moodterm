import SwiftUI

/// An enumeration representing different styles for dynamic fonts.
/// This can be used to apply various font styles that adapt to the user's
/// preferred text size settings.
///
/// Can be:
/// - `body`
/// - `monospaced`
enum DynamicFontStyle {
    case body
    case monospaced

    func specs(factor: Double) -> Font {
        switch self {
        case .body:
            return Font.system(size: 13 * factor, weight: .regular)
        case .monospaced:
            return Font.system(size: 13 * factor, weight: .regular)
        }
    }
}

/// View Extension for Dynamic Font
extension View {
    func dynamicFont(_ style: DynamicFontStyle = .body, factor: Double = 1) -> some View {
        self
            .modifier(DynamicFontModifier(style: style, factor: factor))
    }
}

/// A view modifier that applies a dynamic font style to a view.
struct DynamicFontModifier: ViewModifier {

    let style: DynamicFontStyle
    let factor: Double

    func body(content: Content) -> some View {
        content
            .font(style.specs(factor: factor))
    }
}
