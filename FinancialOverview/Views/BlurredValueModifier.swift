import SwiftUI

struct BlurredValueModifier: ViewModifier {
    let shouldBlur: Bool
    
    func body(content: Content) -> some View {
        Group {
            if shouldBlur {
                Text("••••")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            } else {
                content
            }
        }
    }
}

extension View {
    func blurredValue(_ shouldBlur: Bool) -> some View {
        modifier(BlurredValueModifier(shouldBlur: shouldBlur))
    }
}