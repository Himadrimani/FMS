# FleetCare

FleetCare is an Apple-first Fleet Management System prototype for iOS 26 and iPadOS 26. It translates the supplied SRS into role-specific SwiftUI experiences for fleet managers, drivers, and maintenance personnel.

## Run

1. Open `FleetCare.xcodeproj` in Xcode 26.5 or later.
2. Select an iOS 26 simulator.
3. Build and run the `FleetCare` scheme.
4. Complete onboarding and use any sign-in option.
5. Switch roles from **More → Account → Preview role**.

The current implementation uses realistic local sample data and SwiftData-ready models. Authentication, remote sync, navigation telemetry, camera capture, and ML inference are intentionally represented as integration seams and require deployment-specific services and entitlements.

## Architecture

- SwiftUI with role-specific `TabView` shells and `NavigationStack`
- Observation-based session state
- SwiftData domain models
- Feature-oriented folders
- Semantic asset colors with light/dark variants
- MapKit, Charts, AuthenticationServices, App Intents
- Dynamic Type, VoiceOver labels/values, accessible charts, and 44-point minimum controls

See [PRODUCT_BLUEPRINT.md](Documentation/PRODUCT_BLUEPRINT.md) for the full information architecture, screen catalog, states, user flows, design system, accessibility guidance, and production roadmap.
