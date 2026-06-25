import SwiftUI

struct OnboardingView: View {
    @Environment(SessionStore.self) private var session
    @State private var page = 0

    private let pages = [
        ("Keep every vehicle moving", "See live operations, maintenance, and costs in one trusted place.", "truck.box"),
        ("Make safer decisions", "Surface risks early with clear trends and explainable recommendations.", "checkmark.shield"),
        ("Designed for every role", "Focused tools for managers, drivers, and maintenance teams.", "person.3")
    ]

    var body: some View {
        VStack(spacing: FleetSpacing.xLarge) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: FleetSpacing.xLarge) {
                        Spacer()
                        Image(systemName: item.2)
                            .font(.system(size: 72, weight: .medium))
                            .foregroundStyle(.brandPrimary)
                            .symbolEffect(.breathe, options: .repeating)
                            .accessibilityHidden(true)
                        Text(item.0)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                        Text(item.1)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(FleetSpacing.xLarge)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(page == pages.count - 1 ? "Get Started" : "Continue") {
                if page == pages.count - 1 {
                    session.hasCompletedOnboarding = true
                } else {
                    withAnimation(.smooth) { page += 1 }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, FleetSpacing.xLarge)
            .padding(.bottom, FleetSpacing.large)
            .accessibilityHint(page == pages.count - 1 ? "Opens sign in" : "Shows the next introduction")
        }
        .background(Color.appBackground)
    }
}

#Preview("Onboarding") {
    OnboardingView()
        .environment(SessionStore())
}
