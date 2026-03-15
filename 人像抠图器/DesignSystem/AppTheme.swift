import SwiftUI

enum AppTheme {
    static let shellBackground = Color(red: 1.0, green: 245 / 255, blue: 235 / 255)
    static let shellSurface = Color(red: 1.0, green: 249 / 255, blue: 241 / 255)
    static let shellSurfaceStrong = Color(red: 1.0, green: 240 / 255, blue: 226 / 255)
    static let inkPrimary = Color(red: 23 / 255, green: 20 / 255, blue: 18 / 255)
    static let inkSecondary = Color(red: 109 / 255, green: 98 / 255, blue: 90 / 255)
    static let borderSoft = Color(red: 227 / 255, green: 208 / 255, blue: 192 / 255)
    static let canvasDark = Color(red: 11 / 255, green: 12 / 255, blue: 14 / 255)
    static let canvasElevated = Color(red: 29 / 255, green: 30 / 255, blue: 34 / 255)
    static let accent = Color(red: 1.0, green: 143 / 255, blue: 105 / 255)
    static let accentDeep = Color(red: 230 / 255, green: 87 / 255, blue: 61 / 255)
    static let accentSoft = Color(red: 1.0, green: 216 / 255, blue: 200 / 255)
    static let checkerLight = Color(red: 247 / 255, green: 238 / 255, blue: 231 / 255)
    static let checkerDark = Color(red: 238 / 255, green: 224 / 255, blue: 212 / 255)
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.inkPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.shellSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.borderSoft, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct ToolChipStyle: ButtonStyle {
    var selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(selected ? .white : AppTheme.inkPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(selected ? AppTheme.accent : AppTheme.shellSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(selected ? Color.clear : AppTheme.borderSoft, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SurfaceCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.shellSurface)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.borderSoft.opacity(0.75), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
    }
}

extension View {
    func surfaceCard() -> some View {
        modifier(SurfaceCardModifier())
    }
}
