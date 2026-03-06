import SwiftUI

// MARK: - Register View

struct RegisterView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    // Entrance animation
    @State private var appeared = false

    var body: some View {
        ZStack {
            Theme.bgMainAdaptive(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 40)

                    // MARK: Header
                    headerSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : -20)

                    Spacer()
                        .frame(height: 32)

                    // MARK: Form Card
                    formCard
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Spacer()
                        .frame(height: 24)

                    // MARK: Login Link
                    loginLink
                        .opacity(appeared ? 1 : 0)

                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, Theme.spacingLG)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.bodyMedium)
                    }
                    .foregroundStyle(Theme.brand)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Theme.spacingMD) {
            MosaicLogo(size: 70)
                .shadow(color: Theme.brand.opacity(0.3), radius: 12, x: 0, y: 6)

            Text("Create Account")
                .font(.headingLarge)
                .foregroundStyle(Theme.textPrimary(for: colorScheme))

            Text("Join the Lebanese Arabic community")
                .font(.bodyLarge)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))
        }
    }

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: Theme.spacingMD) {
            // Error Banner
            if let errorMessage {
                errorBanner(errorMessage)
            }

            // Name Field
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "person.fill")
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .frame(width: 20)

                TextField("Full Name", text: $name)
                    .textContentType(.name)
                    .autocorrectionDisabled()
                    .font(.bodyLarge)
            }
            .padding(14)
            .background(Theme.bgSurfaceAdaptive(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                    .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
            )

            // Email Field
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .frame(width: 20)

                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.bodyLarge)
            }
            .padding(14)
            .background(Theme.bgSurfaceAdaptive(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                    .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
            )

            // Password Field
            HStack(spacing: Theme.spacingSM) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Theme.textSecondary(for: colorScheme))
                    .frame(width: 20)

                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .font(.bodyLarge)
            }
            .padding(14)
            .background(Theme.bgSurfaceAdaptive(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.inputRadius, style: .continuous)
                    .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
            )

            // Create Account Button
            Button(action: handleRegister) {
                HStack(spacing: Theme.spacingSM) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.9)
                    }
                    Text(isLoading ? "Creating Account..." : "Create Account")
                        .font(.nunito(16, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Theme.brand, Theme.brand.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.buttonRadius, style: .continuous))
                .shadow(color: Theme.brand.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.top, Theme.spacingSM)
        }
        .padding(Theme.spacingLG)
        .background(Theme.bgCardAdaptive(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .strokeBorder(Theme.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(
            color: Theme.cardShadow(for: colorScheme),
            radius: 12,
            x: 0,
            y: 6
        )
    }

    // MARK: - Login Link

    private var loginLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(.bodyMedium)
                .foregroundStyle(Theme.textSecondary(for: colorScheme))

            Button {
                dismiss()
            } label: {
                Text("Sign In")
                    .font(.nunito(14, weight: .bold))
                    .foregroundStyle(Theme.brand)
            }
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: Theme.spacingSM) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.brand)

            Text(message)
                .font(.bodySmall)
                .foregroundStyle(Theme.brand)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.brandDim)
        .clipShape(RoundedRectangle(cornerRadius: Theme.badgeRadius, style: .continuous))
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty
    }

    private func handleRegister() {
        guard isFormValid else { return }

        errorMessage = nil
        isLoading = true

        Task {
            do {
                try await authService.register(name: name, email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegisterView()
            .environment(AuthService())
    }
}
