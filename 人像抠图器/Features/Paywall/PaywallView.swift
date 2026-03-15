import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseStore: PurchaseStore

    private let features = [
        "paywall.feature.permanent_unlock",
        "paywall.feature.high_resolution",
        "paywall.feature.high_precision",
        "paywall.feature.future_formats",
    ]

    private var purchaseButtonKey: LocalizedStringKey {
        if purchaseStore.hasLifetimeAccess {
            return "paywall.button.already_unlocked"
        }
        if purchaseStore.isPurchasing {
            return "paywall.button.processing"
        }
        return "paywall.button.unlock"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    heroCard
                    featuresCard
                    purchaseCard
                    footerCard
                }
                .padding(20)
                .padding(.bottom, 28)
            }
            .background(AppTheme.shellBackground.ignoresSafeArea())
            .navigationTitle("paywall.nav_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("paywall.close") {
                        dismiss()
                    }
                }
            }
            .onChange(of: purchaseStore.hasLifetimeAccess) { _, isUnlocked in
                if isUnlocked {
                    dismiss()
                }
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("paywall.hero.title")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.inkPrimary)

            Text("paywall.hero.subtitle")
                .font(.body)
                .foregroundStyle(AppTheme.inkSecondary)

            HStack(spacing: 10) {
                accessPill(title: purchaseStore.currentTierTitle, active: purchaseStore.hasLifetimeAccess)

                if purchaseStore.isLoadingProducts {
                    localizedAccessPill("paywall.loading_store", active: false)
                } else {
                    accessPill(title: purchaseStore.lifetimePriceText, active: false)
                }
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var featuresCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("paywall.included")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            ForEach(features, id: \.self) { feature in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accentDeep)
                    Text(LocalizedStringKey(feature))
                        .foregroundStyle(AppTheme.inkPrimary)
                    Spacer()
                }
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var purchaseCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("paywall.purchase.title")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text("paywall.purchase.subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer()

                Text(purchaseStore.lifetimePriceText)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            if purchaseStore.hasLifetimeAccess {
                Label("paywall.unlocked_label", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
            }

            Button {
                Task {
                    if purchaseStore.hasLifetimeAccess {
                        dismiss()
                    } else {
                        await purchaseStore.purchaseLifetime()
                    }
                }
            }
            label: {
                Text(purchaseButtonKey)
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(purchaseStore.isLoadingProducts || purchaseStore.isPurchasing)
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [AppTheme.canvasElevated, AppTheme.canvasDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.34), lineWidth: 1)
        )
    }

    private var footerCard: some View {
        VStack(spacing: 12) {
            Button("paywall.restore_purchases") {
                Task {
                    await purchaseStore.restorePurchases()
                }
            }
            .buttonStyle(.plain)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.inkSecondary)

            Text("paywall.footer.note")
                .font(.caption)
                .foregroundStyle(AppTheme.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private func localizedAccessPill(_ title: LocalizedStringKey, active: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(active ? .white : AppTheme.inkPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(active ? AppTheme.accentDeep : AppTheme.shellSurfaceStrong)
            .clipShape(Capsule())
    }

    private func accessPill(title: String, active: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(active ? .white : AppTheme.inkPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(active ? AppTheme.accentDeep : AppTheme.shellSurfaceStrong)
            .clipShape(Capsule())
    }
}
