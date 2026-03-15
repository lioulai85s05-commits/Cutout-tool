import SwiftUI
import UIKit

private enum ExportAction {
    case saveToPhotos
    case share

    var progressTitle: String {
        switch self {
        case .saveToPhotos:
            return NSLocalizedString("export.progress.saving_to_photos", comment: "")
        case .share:
            return NSLocalizedString("export.progress.preparing_share", comment: "")
        }
    }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let url: URL
}

struct ExportSheetView: View {
    @ObservedObject var project: CutoutProject
    @EnvironmentObject private var model: CutoutAppModel
    @EnvironmentObject private var purchaseStore: PurchaseStore
    @Environment(\.dismiss) private var dismiss

    @State private var format: ExportFormat = .png
    @State private var resolution: ResolutionOption = .standard
    @State private var activeExportAction: ExportAction?
    @State private var noticeMessage: String?
    @State private var errorMessage: String?
    @State private var sharePayload: SharePayload?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    formatCard
                    resolutionCard
                    actionCard
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .background(AppTheme.shellBackground.ignoresSafeArea())
            .navigationTitle("export.nav_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivitySheet(url: payload.url)
        }
        .alert("export.complete_title", isPresented: noticePresented) {
            Button("common.ok", role: .cancel) {
                noticeMessage = nil
            }
        } message: {
            Text(noticeMessage ?? String(localized: "export.complete_message"))
        }
        .alert("export.error_title", isPresented: errorPresented) {
            Button("common.ok", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? String(localized: "export.error_message"))
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("export.summary.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            HStack(spacing: 16) {
                previewThumb

                VStack(alignment: .leading, spacing: 8) {
                    summaryRow("export.summary.object", value: project.selectedObject?.title ?? String(localized: "detection.primary_subject"))
                    summaryRow("export.summary.shape", value: project.shape.title)
                    summaryRow("export.summary.color", value: project.colorMode.title)
                    summaryRow("export.summary.background", value: project.background.title)
                    summaryRow("export.summary.clarity", value: project.clarity.title)
                    summaryRow("export.summary.resolution", value: resolution.title)
                    summaryRow("export.summary.format", value: format.title)
                    summaryRow("export.summary.access", value: purchaseStore.currentTierTitle)
                }
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var previewThumb: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppTheme.canvasDark)

            if let image = project.cutoutUIImage ?? project.originalUIImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .frame(width: 116, height: 116)
    }

    private var formatCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("export.format.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            Text("export.format.subtitle")
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)

            HStack(spacing: 10) {
                ForEach(ExportFormat.allCases) { option in
                    Button(option.title) {
                        format = option
                    }
                    .buttonStyle(ToolChipStyle(selected: format == option))
                }
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var resolutionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("export.resolution.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            ForEach(ResolutionOption.allCases) { option in
                Button {
                    resolution = option
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(option.title)
                                .font(.headline)
                                .foregroundStyle(AppTheme.inkPrimary)
                            Text(option.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.inkSecondary)
                        }

                        Spacer()

                        Image(systemName: resolution == option ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(resolution == option ? AppTheme.accent : AppTheme.borderSoft)
                    }
                    .padding(16)
                    .background(AppTheme.shellSurfaceStrong)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            if resolution == .high {
                if purchaseStore.hasLifetimeAccess {
                    Label("export.resolution.available", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accentDeep)
                } else {
                    Button("export.resolution.unlock_cta") {
                        routeToPaywall()
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accentDeep)
                }
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("export.actions.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            if !purchaseStore.hasLifetimeAccess {
                Label("export.access.locked_note", systemImage: "lock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accentDeep)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.accentSoft.opacity(0.42))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if let activeExportAction {
                HStack(spacing: 12) {
                    ProgressView()
                        .tint(AppTheme.accentDeep)

                    Text(activeExportAction.progressTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.inkPrimary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.accentSoft.opacity(0.42))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Button {
                Task {
                    await saveToPhotos()
                }
            } label: {
                Label {
                    Text(
                        activeExportAction == .saveToPhotos
                        ? "export.actions.saving"
                        : (purchaseStore.hasLifetimeAccess ? "export.actions.save_to_photos" : "export.actions.unlock_to_save")
                    )
                } icon: {
                    Image(systemName: purchaseStore.hasLifetimeAccess ? "square.and.arrow.down" : "lock.fill")
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(activeExportAction != nil)

            Button {
                Task {
                    await shareResult()
                }
            } label: {
                Label {
                    Text(
                        activeExportAction == .share
                        ? "export.actions.preparing"
                        : (purchaseStore.hasLifetimeAccess ? "export.actions.share_result" : "export.actions.unlock_to_share")
                    )
                } icon: {
                    Image(systemName: purchaseStore.hasLifetimeAccess ? "square.and.arrow.up" : "lock.fill")
                }
            }
            .buttonStyle(SecondaryActionButtonStyle())
            .disabled(activeExportAction != nil)
        }
        .padding(22)
        .surfaceCard()
    }

    private func summaryRow(_ title: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppTheme.inkSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.inkPrimary)
        }
        .font(.subheadline)
    }

    private var noticePresented: Binding<Bool> {
        Binding(
            get: { noticeMessage != nil },
            set: { isPresented in
                if !isPresented {
                    noticeMessage = nil
                }
            }
        )
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    private var highResolutionLocked: Bool {
        resolution == .high && !purchaseStore.hasLifetimeAccess
    }

    @MainActor
    private func saveToPhotos() async {
        guard await verifyExportAccess() else {
            return
        }

        activeExportAction = .saveToPhotos
        defer { activeExportAction = nil }

        do {
            let package = try await CutoutExportRenderer.preparePackage(
                project: project,
                format: format,
                resolution: resolution
            )
            try await CutoutExportRenderer.saveToPhotos(package)
            let formatString = NSLocalizedString("export.notice.saved_to_photos_format", comment: "")
            noticeMessage = String(format: formatString, package.suggestedFilename)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func shareResult() async {
        guard await verifyExportAccess() else {
            return
        }

        activeExportAction = .share
        defer { activeExportAction = nil }

        do {
            let package = try await CutoutExportRenderer.preparePackage(
                project: project,
                format: format,
                resolution: resolution
            )
            let url = try CutoutExportRenderer.writeTemporaryFile(package)
            sharePayload = SharePayload(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func verifyExportAccess() async -> Bool {
        guard purchaseStore.hasLifetimeAccess else {
            routeToPaywall()
            return false
        }

        guard highResolutionLocked else {
            return true
        }

        routeToPaywall()
        return false
    }

    @MainActor
    private func routeToPaywall() {
        dismiss()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            model.openPaywall()
        }
    }
}

private struct ActivitySheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
