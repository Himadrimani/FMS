import SwiftUI

struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            if !session.hasCompletedOnboarding {
                OnboardingView()
            } else if !session.isAuthenticated {
                LoginView()
            } else {
                RoleShellView()
            }
        }
        .tint(.brandPrimary)
        .animation(.smooth, value: session.hasCompletedOnboarding)
        .animation(.smooth, value: session.isAuthenticated)
    }
}
