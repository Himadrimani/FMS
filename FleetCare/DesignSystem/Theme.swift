import SwiftUI

enum FleetSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24
    static let xxLarge: CGFloat = 32
}

enum FleetRadius {
    static let card: CGFloat = 18
    static let control: CGFloat = 12
}

struct FleetCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(FleetSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background.secondary, in: .rect(cornerRadius: FleetRadius.card))
    }
}

extension View {
    func fleetCard() -> some View {
        modifier(FleetCardModifier())
    }
}
