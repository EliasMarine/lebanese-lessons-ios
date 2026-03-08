import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var studyGoalMinutes = 10

    private let goalOptions = [5, 10, 15, 20, 30]

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Theme.brand.opacity(0.3),
                    Theme.brightPurple.opacity(0.2),
                    Theme.electricBlue.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                namePage.tag(1)
                goalPage.tag(2)
                readyPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
        }
    }

    // MARK: - Welcome Page

    private var welcomePage: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()

            MosaicLogo(size: 100)
                .fadeUpAnimation()

            VStack(spacing: Theme.spacingSM) {
                Text("Lebanese Learn")
                    .font(.nunito(34, weight: .bold))
                    .foregroundStyle(.primary)
                    .fadeUpAnimation(delay: 0.1)

                Text("Master Lebanese Arabic\nwith immersive lessons")
                    .font(.bodyLarge)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fadeUpAnimation(delay: 0.2)
            }

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Get Started")
                    .font(.headingSmall)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .duoButtonProminent(tint: Theme.brand)
            .buttonStyle(DuoPressStyle())
            .fadeUpAnimation(delay: 0.3)

            Spacer()
                .frame(height: Theme.spacingXL)
        }
        .padding(.horizontal, Theme.spacingLG)
    }

    // MARK: - Name Page

    private var namePage: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.electricBlue)
                .fadeUpAnimation()

            VStack(spacing: Theme.spacingSM) {
                Text("What should we call you?")
                    .font(.headingLarge)
                    .multilineTextAlignment(.center)
                    .fadeUpAnimation(delay: 0.1)

                Text("Your name will appear on the leaderboard")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
                    .fadeUpAnimation(delay: 0.15)
            }

            TextField("Your name", text: $userName)
                .font(.bodyLarge)
                .multilineTextAlignment(.center)
                .padding(Theme.spacingMD)
                .duoInput()
                .fadeUpAnimation(delay: 0.2)

            Spacer()

            Button {
                withAnimation { currentPage = 2 }
            } label: {
                Text("Continue")
                    .font(.headingSmall)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .duoButtonProminent(tint: Theme.duoBlue)
            .buttonStyle(DuoPressStyle())
            .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(userName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)

            Spacer()
                .frame(height: Theme.spacingXL)
        }
        .padding(.horizontal, Theme.spacingLG)
    }

    // MARK: - Goal Page

    private var goalPage: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()

            Image(systemName: "target")
                .font(.system(size: 64))
                .foregroundStyle(Theme.vividGreen)
                .fadeUpAnimation()

            VStack(spacing: Theme.spacingSM) {
                Text("Daily study goal")
                    .font(.headingLarge)
                    .fadeUpAnimation(delay: 0.1)

                Text("How many minutes per day?")
                    .font(.bodyMedium)
                    .foregroundStyle(.secondary)
                    .fadeUpAnimation(delay: 0.15)
            }

            VStack(spacing: Theme.spacingMD) {
                ForEach(goalOptions, id: \.self) { minutes in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            studyGoalMinutes = minutes
                        }
                    } label: {
                        HStack {
                            Text("\(minutes) min")
                                .font(.headingSmall)
                            Spacer()
                            if studyGoalMinutes == minutes {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.vividGreen)
                            }
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, Theme.spacingMD)
                        .padding(.vertical, Theme.spacingSM)
                    }
                    .background(
                        studyGoalMinutes == minutes
                            ? Theme.vividGreen
                            : Theme.surface
                    )
                    .foregroundStyle(studyGoalMinutes == minutes ? .white : .primary)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                studyGoalMinutes == minutes ? Theme.vividGreen : Color.gray.opacity(0.15),
                                lineWidth: 2
                            )
                    )
                }
            }
            .fadeUpAnimation(delay: 0.2)

            Spacer()

            Button {
                withAnimation { currentPage = 3 }
            } label: {
                Text("Continue")
                    .font(.headingSmall)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .duoButtonProminent(tint: Theme.vividGreen)
            .buttonStyle(DuoPressStyle())

            Spacer()
                .frame(height: Theme.spacingXL)
        }
        .padding(.horizontal, Theme.spacingLG)
    }

    // MARK: - Ready Page

    private var readyPage: some View {
        VStack(spacing: Theme.spacingXL) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(Theme.goldenYellow)
                .fadeUpAnimation()

            VStack(spacing: Theme.spacingSM) {
                Text("You're all set!")
                    .font(.headingLarge)
                    .fadeUpAnimation(delay: 0.1)

                Text("Start your journey to fluency\nin Lebanese Arabic")
                    .font(.bodyLarge)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fadeUpAnimation(delay: 0.15)
            }

            VStack(spacing: Theme.spacingSM) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Theme.electricBlue)
                    Text(userName.isEmpty ? "Learner" : userName)
                        .font(.bodyLarge)
                    Spacer()
                }
                HStack {
                    Image(systemName: "target")
                        .foregroundStyle(Theme.vividGreen)
                    Text("\(studyGoalMinutes) min / day")
                        .font(.bodyLarge)
                    Spacer()
                }
            }
            .duoCard()
            .fadeUpAnimation(delay: 0.2)

            Spacer()

            Button {
                completeOnboarding()
            } label: {
                Text("Start Learning")
                    .font(.headingSmall)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .duoButtonProminent(tint: Theme.brand)
            .buttonStyle(DuoPressStyle())
            .fadeUpAnimation(delay: 0.3)

            Spacer()
                .frame(height: Theme.spacingXL)
        }
        .padding(.horizontal, Theme.spacingLG)
    }

    // MARK: - Actions

    private func completeOnboarding() {
        let displayName = userName.trimmingCharacters(in: .whitespaces)
        let profile = UserProfile(
            name: displayName.isEmpty ? "Learner" : displayName,
            studyGoalMinutes: studyGoalMinutes,
            hasCompletedOnboarding: true
        )
        modelContext.insert(profile)
        try? modelContext.save()
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}
