import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                NavigationStack {
                    DashboardView()
                }
            }

            Tab("Learn", systemImage: "book.fill", value: 1) {
                NavigationStack {
                    LessonsListView()
                }
            }

            Tab("Review", systemImage: "brain.head.profile", value: 2) {
                NavigationStack {
                    ReviewDashboardView()
                }
            }

            Tab("Rank", systemImage: "trophy.fill", value: 3) {
                NavigationStack {
                    LeaderboardView()
                }
            }

            Tab("Profile", systemImage: "person.fill", value: 4) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(Theme.brand)
    }
}
