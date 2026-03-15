import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: CutoutAppModel
    @EnvironmentObject private var purchaseStore: PurchaseStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                sectionCard(
                    title: "settings.access.heading",
                    rows: [
                        ("settings.access.current_tier", purchaseStore.currentTierTitle),
                        ("settings.access.unlock_model", purchaseStore.unlockModelTitle),
                        ("settings.access.lifetime_product", purchaseStore.lifetimePriceText),
                    ]
                )

                languageCard

                sectionCard(
                    title: "settings.privacy.heading",
                    rows: [
                        ("settings.privacy.processing", String(localized: "settings.privacy.processing.value")),
                        ("settings.privacy.photo_access", String(localized: "settings.privacy.photo_access.value")),
                    ]
                )

                VStack(alignment: .leading, spacing: 14) {
                    Text("settings.support.heading")
                        .font(.headline)
                        .foregroundStyle(AppTheme.inkPrimary)

                    Link(destination: URL(string: "mailto:luodan91918@gamil.com")!) {
                        supportRow(
                            title: "settings.support.contact_support",
                            value: "luodan91918@gamil.com",
                            systemImage: "envelope.fill"
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task {
                            await purchaseStore.restorePurchases()
                        }
                    } label: {
                        supportRow(
                            title: "settings.support.restore_purchases",
                            value: String(localized: "settings.support.restore_source"),
                            systemImage: "arrow.clockwise"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .surfaceCard()
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .background(AppTheme.shellBackground.ignoresSafeArea())
        .navigationTitle("settings.nav_title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var languageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("settings.language.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            Picker("settings.language.picker", selection: $model.selectedLanguage) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.title).tag(language)
                }
            }
            .pickerStyle(.menu)
            .tint(AppTheme.accentDeep)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .topLeading)
        .surfaceCard()
    }

    private func sectionCard(title: LocalizedStringKey, rows: [(LocalizedStringKey, String)]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack {
                    Text(row.0)
                        .foregroundStyle(AppTheme.inkSecondary)
                    Spacer()
                    Text(row.1)
                        .foregroundStyle(AppTheme.inkPrimary)
                }
                .font(.subheadline)
            }
        }
        .padding(20)
        .surfaceCard()
    }

    private func supportRow(title: LocalizedStringKey, value: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(AppTheme.accentDeep)
                .frame(width: 18)

            Text(title)
                .foregroundStyle(AppTheme.inkPrimary)

            Spacer()

            Text(value)
                .foregroundStyle(AppTheme.inkSecondary)
        }
        .font(.subheadline)
        .padding(16)
        .background(AppTheme.shellSurfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
