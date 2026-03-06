import SwiftUI

// MARK: - Content View

/// Root view that switches between authentication and the main app
/// based on the current auth state, with a splash screen while checking.
struct ContentView: View {
    @Environment(AuthService.self) private var authService

    @State private var hasCheckedSession = false
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            } else if authService.isAuthenticated {
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showSplash)
        .animation(.easeInOut(duration: 0.35), value: authService.isAuthenticated)
        .task {
            guard !hasCheckedSession else { return }
            hasCheckedSession = true
            await authService.checkSession()

            // Small delay for a polished splash reveal
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation {
                showSplash = false
            }
        }
    }
}

// MARK: - Splash Screen

/// Minimal loading screen shown while the session is being validated.
private struct SplashScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            Theme.bgMainAdaptive(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: Theme.spacingLG) {
                MosaicLogo(size: 80)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Text("Lebanese Learn")
                    .font(.headingLarge)
                    .foregroundStyle(Theme.textPrimary(for: colorScheme))
                    .opacity(logoOpacity)

                ProgressView()
                    .tint(Theme.brand)
                    .scaleEffect(1.1)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(AuthService())
}
