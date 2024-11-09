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
            return Font.system(size: 10  * factor, weight: .regular)
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
struct DynamicFontModifier: ViewModifier  {
    
    let style: DynamicFontStyle
    let factor: Double
    
    func body(content: Content) -> some View {
        content
            .font(style.specs(factor: factor))
    }
}