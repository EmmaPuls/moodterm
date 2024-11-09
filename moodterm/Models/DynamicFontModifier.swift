/// A SwiftUI modifier and supporting types to dynamically adjust font styles based on a scaling factor.
///
/// The `DynamicFontStyle` enum defines various font styles that can be used within the app.
/// Each style has a method to return a `Font` object with a size adjusted by a given factor.
///
/// The `DynamicFontModifier` struct is a `ViewModifier` that applies the specified dynamic font style
/// to a view, scaling the font size by the provided factor.
///
/// The `View` extension provides a convenience method `dynamicFont(_:factor:)` to easily apply the
/// `DynamicFontModifier` to any view.
///
/// Usage:
/// ```swift
/// Text("Hello, World!")
///     .dynamicFont(.title, factor: 1.5)
/// ```
///
/// - `DynamicFontStyle`: Enum defining different font styles.
/// - `DynamicFontStyle.specs(factor:)`: Method to get a `Font` object with adjusted size.
/// - `DynamicFontModifier`: View modifier to apply dynamic font styles.
/// - `View.dynamicFont(_:factor:)`: Convenience method to apply the dynamic font modifier.

import SwiftUI

enum DynamicFontStyle {
    case largeTitle
    case title
    case headline
    case body
    case caption
    case monospaced

    func specs(factor: Double) -> Font {
        switch self {
        case .largeTitle:
            return Font.system(size: 26 * factor, weight: .regular)
        case .title:
            return Font.system(size: 22 * factor, weight: .regular)
        case .headline:
            return Font.system(size: 13 * factor, weight: .bold)
        case .body:
            return Font.system(size: 13 * factor, weight: .regular)
        case .caption:
            return Font.system(size: 10 * factor, weight: .regular)
        case .monospaced:
            return Font.system(size: 13 * factor, weight: .regular)
        }
    }
}

// View expension for ease of use
extension View {
    func dynamicFont(_ style: DynamicFontStyle = .body, factor: Double = 1) -> some View {
        self
            .modifier(DynamicFontModifier(style: style, factor: factor))
    }
}

// View Modifier
struct DynamicFontModifier: ViewModifier {

    let style: DynamicFontStyle
    let factor: Double

    func body(content: Content) -> some View {
        content
            .font(style.specs(factor: factor))
    }
}
