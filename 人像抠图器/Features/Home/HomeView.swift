import PhotosUI
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var model: CutoutAppModel
    @EnvironmentObject private var purchaseStore: PurchaseStore

    private let showcases = [
        HomeShowcase(titleKey: "home.showcase.products.title", subtitleKey: "home.showcase.products.subtitle", symbol: "shippingbox.fill"),
        HomeShowcase(titleKey: "home.showcase.people.title", subtitleKey: "home.showcase.people.subtitle", symbol: "person.crop.square.fill"),
        HomeShowcase(titleKey: "home.showcase.pets.title", subtitleKey: "home.showcase.pets.subtitle", symbol: "pawprint.fill"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroSection
                launchSection
                recentSection
                showcaseSection
                unlockSection
            }
            .padding(20)
            .padding(.bottom, 32)
        }
        .background(AppTheme.shellBackground.ignoresSafeArea())
        .navigationTitle("home.nav_title")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: model.openSettings) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(AppTheme.inkPrimary)
                }
            }
        }
        .onChange(of: model.selectedPhotoItem?.itemIdentifier) { _, newValue in
            guard newValue != nil, let item = model.selectedPhotoItem else {
                return
            }

            Task {
                await model.handleSelectedPhotoSelection(item)
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("home.hero.title")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.inkPrimary)
                }

                Spacer(minLength: 0)

                ObjectRingHeroMark()
                    .frame(width: 108, height: 108)
            }

            processStrip
        }
        .padding(24)
        .surfaceCard()
    }

    private var launchSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("home.launch.heading")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.inkPrimary)

            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.canvasElevated, AppTheme.canvasDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .fill(AppTheme.accent.opacity(0.18))
                    .frame(width: 210, height: 210)
                    .blur(radius: 45)
                    .offset(x: 90, y: -40)

                VStack(alignment: .leading, spacing: 16) {
                    Text("home.launch.workflow_title")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("home.launch.workflow_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))

                    PhotosPicker(selection: $model.selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text("home.launch.choose_photo")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
                .padding(22)
            }
            .frame(height: 220)
        }
        .padding(24)
        .surfaceCard()
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("home.recent.heading")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.inkPrimary)
                Spacer()
                Text("\(model.recentProjects.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.inkSecondary)
            }

            if model.recentProjects.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("home.recent.empty_title")
                        .font(.headline)
                        .foregroundStyle(AppTheme.inkPrimary)
                    Text("home.recent.empty_subtitle")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(AppTheme.shellSurfaceStrong)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(model.recentProjects.prefix(6))) { project in
                            Button {
                                model.openProject(project)
                            } label: {
                                RecentProjectCard(project: project)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(24)
        .surfaceCard()
    }

    private var showcaseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("home.showcase.heading")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.inkPrimary)

            ForEach(showcases) { item in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(iconFill)
                            .frame(width: 56, height: 56)
                        Image(systemName: item.symbol)
                            .font(.title3)
                            .foregroundStyle(AppTheme.accentDeep)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.titleKey)
                            .font(.headline)
                            .foregroundStyle(AppTheme.inkPrimary)
                        Text(item.subtitleKey)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.inkSecondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(AppTheme.shellSurfaceStrong)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .padding(24)
        .surfaceCard()
    }

    private var unlockSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(purchaseStore.hasLifetimeAccess ? "home.unlock.title.unlocked" : "home.unlock.title.free")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.inkPrimary)

            Text(purchaseStore.hasLifetimeAccess
                 ? "home.unlock.subtitle.unlocked"
                 : "home.unlock.subtitle.free")
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)

            Button(action: model.openPaywall) {
                HStack {
                    Text(purchaseStore.hasLifetimeAccess ? "home.unlock.cta.unlocked" : "home.unlock.cta.free")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
        .padding(24)
        .surfaceCard()
    }

    private var processStrip: some View {
        HStack(spacing: 8) {
            processPill("workflow.upload", emphasized: true)
            processPill("workflow.recognize", emphasized: true)
            processPill("workflow.select", emphasized: false)
            processPill("workflow.extract", emphasized: false)
            processPill("workflow.save", emphasized: false)
        }
    }

    private func processPill(_ title: LocalizedStringKey, emphasized: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(emphasized ? AppTheme.accentDeep : AppTheme.inkSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(emphasized ? AppTheme.accentSoft : AppTheme.shellSurfaceStrong)
            .clipShape(Capsule())
    }

    private var iconFill: some ShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: [AppTheme.accent.opacity(0.18), AppTheme.accentDeep.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct HomeShowcase: Identifiable {
    let id = UUID()
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey
    let symbol: String
}

private struct ObjectRingHeroMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.shellSurfaceStrong, AppTheme.shellSurface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .stroke(AppTheme.borderSoft, lineWidth: 12)
                .frame(width: 66, height: 66)

            Circle()
                .fill(AppTheme.canvasDark)
                .frame(width: 34, height: 34)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accentDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 18, height: 18)
                .offset(x: 28, y: 20)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 18, height: 18)
                        .offset(x: 28, y: 20)
                )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(AppTheme.borderSoft.opacity(0.7), lineWidth: 1)
        )
    }
}

private struct RecentProjectCard: View {
    @ObservedObject var project: CutoutProject

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.canvasDark)

                if let image = project.cutoutUIImage ?? project.originalUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 156, height: 124)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .frame(width: 156, height: 124)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(project.name)
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)
                .lineLimit(1)

            Text(project.createdAtText)
                .font(.caption)
                .foregroundStyle(AppTheme.inkSecondary)
        }
        .padding(12)
        .frame(width: 180, alignment: .leading)
        .background(AppTheme.shellSurfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
