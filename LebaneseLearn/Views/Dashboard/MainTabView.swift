import SwiftUI

// MARK: - Main Tab View

/// Bottom tab bar with 5 sections, styled with the brand accent color.
struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Tab.allCases) { tab in
                tab.destination
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tint(Theme.brand)
    }
}

// MARK: - Tab Definition

extension MainTabView {

    enum Tab: String, CaseIterable, Identifiable {
        case home
        case lessons
        case review
        case leaderboard
        case profile

        var id: String { rawValue }

        var title: String {
            switch self {
            case .home:        return "Home"
            case .lessons:     return "Lessons"
            case .review:      return "Review"
            case .leaderboard: return "Leaderboard"
            case .profile:     return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .home:        return "house.fill"
            case .lessons:     return "book.fill"
            case .review:      return "brain.head.profile"
            case .leaderboard: return "trophy.fill"
            case .profile:     return "person.fill"
            }
        }

        @ViewBuilder
        var destination: some View {
            switch self {
            case .home:
                DashboardView()
            case .lessons:
                NavigationStack {
                    LessonsListView()
                }
            case .review:
                NavigationStack {
                    ReviewDashboardView()
                }
            case .leaderboard:
                NavigationStack {
                    LeaderboardView()
                }
            case .profile:
                NavigationStack {
                    ProfileView()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(AuthService())
}
