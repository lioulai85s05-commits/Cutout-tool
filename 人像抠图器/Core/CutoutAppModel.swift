import Combine
import Foundation
import PhotosUI
import SwiftUI

@MainActor
final class CutoutAppModel: ObservableObject {
    private let processor: any PortraitCutoutProcessing

    @Published var path = NavigationPath()
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var currentProject: CutoutProject?
    @Published var recentProjects: [CutoutProject] = []
    @Published var processingState: ProcessingSnapshot?
    @Published var isShowingExportSheet = false
    @Published var isShowingPaywall = false
    @Published var selectedLanguage: AppLanguage = .system
    @Published var errorMessage: String?

    init(processor: any PortraitCutoutProcessing = LocalVisionPortraitCutoutProcessor()) {
        self.processor = processor
    }

    func handleSelectedPhotoSelection(_ item: PhotosPickerItem) async {
        selectedPhotoItem = nil

        do {
            guard let data = try await item.loadTransferable(type: Data.self), !data.isEmpty else {
                return
            }

            await startLocalProcessing(imageData: data, suggestedName: makeProjectName())
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openProject(_ project: CutoutProject) {
        currentProject = project
        path = NavigationPath()
        path.append(AppRoute.editor)
    }

    func openRecognition() {
        guard currentProject != nil else {
            return
        }
        path = NavigationPath()
        path.append(AppRoute.recognition)
    }

    func openEditor() {
        guard currentProject != nil else {
            return
        }
        path.append(AppRoute.editor)
    }

    func openSettings() {
        path.append(AppRoute.settings)
    }

    func openExport() {
        isShowingExportSheet = true
    }

    func openPaywall() {
        isShowingPaywall = true
    }

    func resetCurrentProject() {
        currentProject?.resetEditing()
    }

    private func startLocalProcessing(imageData: Data, suggestedName: String) async {
        do {
            let output = try await processor.process(imageData: imageData) { [weak self] stage in
                await MainActor.run {
                    self?.processingState = ProcessingSnapshot(
                        progress: stage.progress,
                        stageTitle: stage.title,
                        detail: stage.detail,
                        imageData: imageData
                    )
                }
            }

            let project = CutoutProject(
                name: suggestedName,
                originalImageData: output.originalImageData,
                cutoutImageData: output.cutoutImageData,
                detectedObjectOutputs: output.detectedObjects
            )
            currentProject = project
            recentProjects.insert(project, at: 0)
            if recentProjects.count > 8 {
                recentProjects.removeLast(recentProjects.count - 8)
            }

            processingState = nil
            path = NavigationPath()
            path.append(AppRoute.recognition)
        } catch is CancellationError {
            processingState = nil
        } catch {
            processingState = nil
            errorMessage = error.localizedDescription
        }
    }

    private func makeProjectName() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = projectNamingLocale
        let format = NSLocalizedString("project.name.format", comment: "")
        return String(format: format, formatter.string(from: .now))
    }

    private var projectNamingLocale: Locale {
        guard let localeIdentifier = selectedLanguage.localeIdentifier else {
            return .autoupdatingCurrent
        }
        return Locale(identifier: localeIdentifier)
    }
}
