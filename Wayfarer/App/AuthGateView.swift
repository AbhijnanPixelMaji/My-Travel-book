//
//  AuthGateView.swift
//  Wayfarer
//

import SwiftUI
import UIKit

struct AuthGateView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @State private var isShowingLaunchOverlay = true

    var body: some View {
        ZStack {
            Group {
                if isAuthenticated {
                    RootTabView()
                } else {
                    LoginRegistrationView()
                }
            }
            .opacity(isShowingLaunchOverlay ? 0 : 1)

            if isShowingLaunchOverlay {
                GamifiedLaunchOverlay {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isShowingLaunchOverlay = false
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: isAuthenticated)
    }
}

private enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Sign in"
    case register = "Create"

    var id: String { rawValue }
}

struct LoginRegistrationView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("travelerName") private var travelerName = ""
    @AppStorage("travelerEmail") private var travelerEmail = ""

    @State private var mode: AuthMode = .login
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var errorMessage = ""
    @State private var acceptedTerms = true

    private var isRegistering: Bool { mode == .register }

    var body: some View {
        NavigationStack {
            ZStack {
                WayfarerTheme.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 22) {
                        brandHeader
                        authCard
                        trustStrip
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
        }
        .onAppear {
            name = travelerName
            email = travelerEmail
        }
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            AnimatedLogoMark(size: 86, cornerRadius: 24)

            VStack(spacing: 6) {
                Text("Wayfarer")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(WayfarerTheme.ink)
                Text("Your calm travel command center.")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 16)
    }

    private var authCard: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $mode) {
                ForEach(AuthMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: mode) { _, _ in errorMessage = "" }

            VStack(alignment: .leading, spacing: 10) {
                Text(isRegistering ? "Create your travel profile" : "Welcome back")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(WayfarerTheme.ink)
                Text(isRegistering ? "Start with a profile you can use offline for trips, tickets, memories, and safety." : "Sign in to continue planning, storing, and protecting your journeys.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                if isRegistering {
                    authField(title: "Full name", text: $name, systemImage: "person.fill", keyboard: .default)
                }
                authField(title: "Email", text: $email, systemImage: "envelope.fill", keyboard: .emailAddress)
                passwordField(title: "Password", text: $password)
                if isRegistering {
                    passwordField(title: "Confirm password", text: $confirmPassword)
                    Toggle(isOn: $acceptedTerms) {
                        Text("I agree to keep my emergency and travel details accurate.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .toggleStyle(.switch)
                }
            }

            if !errorMessage.isEmpty {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: submit) {
                HStack {
                    Text(isRegistering ? "Create account" : "Sign in")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(WayfarerTheme.primaryGradient, in: RoundedRectangle(cornerRadius: 16))
                .foregroundStyle(.white)
                .shadow(color: WayfarerTheme.ocean.opacity(0.24), radius: 12, x: 0, y: 8)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    mode = isRegistering ? .login : .register
                    errorMessage = ""
                }
            } label: {
                Text(isRegistering ? "Already have an account? Sign in" : "New here? Create an account")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(WayfarerTheme.ocean)
            }
        }
        .padding(18)
        .background {
            ZStack(alignment: .topTrailing) {
                Color(.secondarySystemGroupedBackground)
                AmbientTravelMotion(tint: WayfarerTheme.reef)
                    .opacity(0.35)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .shadow(color: .black.opacity(0.09), radius: 22, x: 0, y: 12)
    }

    private var trustStrip: some View {
        HStack(spacing: 10) {
            miniTrustItem("Offline", "wifi.slash", WayfarerTheme.ocean)
            miniTrustItem("Private", "lock.fill", WayfarerTheme.lavender)
            miniTrustItem("SOS ready", "sos.circle.fill", .red)
        }
    }

    private func miniTrustItem(_ title: String, _ icon: String, _ tint: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: Circle())
                .foregroundStyle(tint)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
    }

    private func authField(title: String, text: Binding<String>, systemImage: String, keyboard: UIKeyboardType) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(WayfarerTheme.ocean)
                .frame(width: 24)
            TextField(title, text: text)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .keyboardType(keyboard)
                .autocorrectionDisabled(keyboard == .emailAddress)
        }
        .padding(13)
        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func passwordField(title: String, text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "key.fill")
                .foregroundStyle(WayfarerTheme.sunrise)
                .frame(width: 24)
            Group {
                if showPassword {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(13)
        .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func submit() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            errorMessage = "Enter a valid email address."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        if isRegistering {
            guard !trimmedName.isEmpty else {
                errorMessage = "Enter your name."
                return
            }
            guard password == confirmPassword else {
                errorMessage = "Passwords do not match."
                return
            }
            guard acceptedTerms else {
                errorMessage = "Please confirm your travel details pledge."
                return
            }
            travelerName = trimmedName
        }

        travelerEmail = trimmedEmail
        errorMessage = ""
        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
            isAuthenticated = true
        }
    }
}

#Preview {
    LoginRegistrationView()
}
