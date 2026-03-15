import SwiftUI

struct ContentView: View {
    @StateObject private var model = CutoutAppModel()
    @StateObject private var purchaseStore = PurchaseStore()

    var body: some View {
        NavigationStack(path: $model.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self, destination: destinationView)
        }
        .environmentObject(model)
        .environmentObject(purchaseStore)
        .environment(\.locale, model.selectedLanguage.locale)
        .tint(AppTheme.accent)
        .task {
            await purchaseStore.prepare()
        }
        .sheet(isPresented: $model.isShowingExportSheet) {
            if let project = model.currentProject {
                ExportSheetView(project: project)
                    .environmentObject(model)
                    .environmentObject(purchaseStore)
                    .environment(\.locale, model.selectedLanguage.locale)
            }
        }
        .sheet(isPresented: $model.isShowingPaywall) {
            PaywallView()
                .environmentObject(model)
                .environmentObject(purchaseStore)
                .environment(\.locale, model.selectedLanguage.locale)
        }
        .fullScreenCover(isPresented: processingPresented) {
            ProcessingView()
                .environmentObject(model)
                .environmentObject(purchaseStore)
                .environment(\.locale, model.selectedLanguage.locale)
        }
        .alert("content.alert.processing_error", isPresented: errorAlertPresented) {
            Button("common.ok", role: .cancel) {
                model.errorMessage = nil
            }
        } message: {
            Text(model.errorMessage ?? String(localized: "content.alert.processing_error.message"))
        }
        .alert("content.alert.store_notice", isPresented: storeNoticePresented) {
            Button("common.ok", role: .cancel) {
                purchaseStore.noticeMessage = nil
            }
        } message: {
            Text(purchaseStore.noticeMessage ?? String(localized: "content.alert.store_notice.message"))
        }
        .alert("content.alert.store_error", isPresented: storeErrorPresented) {
            Button("common.ok", role: .cancel) {
                purchaseStore.errorMessage = nil
            }
        } message: {
            Text(purchaseStore.errorMessage ?? String(localized: "content.alert.store_error.message"))
        }
    }

    @ViewBuilder
    private func destinationView(_ route: AppRoute) -> some View {
        switch route {
        case .recognition:
            if let project = model.currentProject {
                RecognitionView(project: project)
            } else {
                HomeView()
            }
        case .editor:
            if let project = model.currentProject {
                EditorView(project: project)
            } else {
                HomeView()
            }
        case .settings:
            SettingsView()
        }
    }

    private var processingPresented: Binding<Bool> {
        Binding(
            get: { model.processingState != nil },
            set: { isPresented in
                if !isPresented {
                    model.processingState = nil
                }
            }
        )
    }

    private var errorAlertPresented: Binding<Bool> {
        Binding(
            get: { model.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    model.errorMessage = nil
                }
            }
        )
    }

    private var storeNoticePresented: Binding<Bool> {
        Binding(
            get: { purchaseStore.noticeMessage != nil },
            set: { isPresented in
                if !isPresented {
                    purchaseStore.noticeMessage = nil
                }
            }
        )
    }

    private var storeErrorPresented: Binding<Bool> {
        Binding(
            get: { purchaseStore.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    purchaseStore.errorMessage = nil
                }
            }
        )
    }
}
