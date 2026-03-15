import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import Photos
import UIKit
import UniformTypeIdentifiers

struct CutoutExportInput: Sendable {
    let projectName: String
    let selectedObjectTitle: String
    let sourceImageData: Data
    let shape: ShapeOption
    let colorMode: ColorOption
    let background: BackgroundOption
    let clarity: ClarityOption
    let cropOffsetUnit: CGSize
}

struct CutoutExportPackage: Sendable {
    let image: UIImage
    let data: Data
    let suggestedFilename: String
    let type: UTType
}

enum CutoutExportError: LocalizedError, Sendable {
    case missingImage
    case encodingFailed
    case photoAccessDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .missingImage:
            return NSLocalizedString("export.error.missing_image", comment: "")
        case .encodingFailed:
            return NSLocalizedString("export.error.encoding_failed", comment: "")
        case .photoAccessDenied:
            return NSLocalizedString("export.error.photo_access_denied", comment: "")
        case .saveFailed:
            return NSLocalizedString("export.error.save_failed", comment: "")
        }
    }
}

enum CutoutExportRenderer {
    nonisolated private static let ciContext = CIContext(options: nil)
    nonisolated private static let cropOverscanScale: CGFloat = 1.28

    @MainActor
    static func preparePackage(
        project: CutoutProject,
        format: ExportFormat,
        resolution: ResolutionOption
    ) async throws -> CutoutExportPackage {
        let input = try makeInput(from: project)

        return try await Task.detached(priority: .userInitiated) {
            try render(
                input: input,
                format: format,
                resolution: resolution
            )
        }.value
    }

    nonisolated static func render(
        input: CutoutExportInput,
        format: ExportFormat,
        resolution: ResolutionOption
    ) throws -> CutoutExportPackage {
        guard let sourceImage = UIImage(data: input.sourceImageData) else {
            throw CutoutExportError.missingImage
        }

        let adjustedImage = applyAdjustments(
            to: sourceImage,
            colorMode: input.colorMode,
            clarity: input.clarity
        )

        let sideLength = canvasSide(for: adjustedImage.size, resolution: resolution)
        let canvasSize = CGSize(width: sideLength, height: sideLength)
        let canvasRect = CGRect(origin: .zero, size: canvasSize)
        let cropRect = cropRect(for: input.shape, in: canvasRect)
        let drawRect = translatedAspectFillRect(
            for: adjustedImage.size,
            in: cropRect,
            offsetUnit: input.cropOffsetUnit
        )

        let opaque = format == .jpg || input.background != .transparent
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = 1
        rendererFormat.opaque = opaque

        let renderedImage = UIGraphicsImageRenderer(size: canvasSize, format: rendererFormat).image { rendererContext in
            let context = rendererContext.cgContext
            let fillColor = backgroundColor(for: input.background, format: format)

            if fillColor != .clear {
                fillColor.setFill()
                context.fill(canvasRect)
            } else {
                context.clear(canvasRect)
            }

            context.saveGState()
            shapePath(for: input.shape, in: cropRect).addClip()
            adjustedImage.draw(in: drawRect)
            context.restoreGState()
        }

        let type: UTType = format == .png ? .png : .jpeg
        let data: Data?

        switch format {
        case .png:
            data = renderedImage.pngData()
        case .jpg:
            data = renderedImage.jpegData(compressionQuality: 0.94)
        }

        guard let data else {
            throw CutoutExportError.encodingFailed
        }

        return CutoutExportPackage(
            image: renderedImage,
            data: data,
            suggestedFilename: suggestedFilename(for: input, format: format),
            type: type
        )
    }

    nonisolated static func saveToPhotos(_ package: CutoutExportPackage) async throws {
        let authorizationStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            throw CutoutExportError.photoAccessDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCreationRequest.forAsset()
                let options = PHAssetResourceCreationOptions()
                options.originalFilename = package.suggestedFilename
                request.addResource(with: .photo, data: package.data, options: options)
            }, completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: CutoutExportError.saveFailed)
                }
            })
        }
    }

    nonisolated static func writeTemporaryFile(_ package: CutoutExportPackage) throws -> URL {
        let exportDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("CutoutExports", isDirectory: true)
        try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)

        let url = exportDirectory.appendingPathComponent(package.suggestedFilename)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try package.data.write(to: url, options: .atomic)
        return url
    }

    nonisolated private static func applyAdjustments(
        to image: UIImage,
        colorMode: ColorOption,
        clarity: ClarityOption
    ) -> UIImage {
        guard let ciInput = CIImage(image: image) else {
            return image
        }

        let controls = CIFilter.colorControls()
        controls.inputImage = ciInput

        switch colorMode {
        case .original:
            controls.saturation = 1.0
            controls.contrast = clarityContrast(for: clarity)
            controls.brightness = 0
        case .grayscale:
            controls.saturation = 0
            controls.contrast = clarityContrast(for: clarity)
            controls.brightness = 0
        case .blackWhite:
            controls.saturation = 0
            controls.contrast = clarityContrast(for: clarity) + 0.65
            controls.brightness = 0.04
        }

        var outputImage = controls.outputImage ?? ciInput

        if clarity == .sharp {
            let sharpen = CIFilter.sharpenLuminance()
            sharpen.inputImage = outputImage
            sharpen.sharpness = 0.55
            outputImage = sharpen.outputImage ?? outputImage
        }

        guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
    }

    nonisolated private static func clarityContrast(for clarity: ClarityOption) -> Float {
        switch clarity {
        case .soft:
            return 0.94
        case .standard:
            return 1.04
        case .sharp:
            return 1.18
        }
    }

    nonisolated private static func canvasSide(for size: CGSize, resolution: ResolutionOption) -> CGFloat {
        let longestSide = max(size.width, size.height)
        let baseline = max(longestSide, 1024)

        switch resolution {
        case .standard:
            return min(max(baseline, 1440), 1800)
        case .high:
            return min(max(baseline * 1.4, 2200), 3072)
        }
    }

    nonisolated private static func cropRect(for shape: ShapeOption, in canvasRect: CGRect) -> CGRect {
        let inset = shape == .circle ? canvasRect.width * 0.07 : canvasRect.width * 0.06
        let availableRect = canvasRect.insetBy(dx: inset, dy: inset)

        if shape == .circle {
            let side = min(availableRect.width, availableRect.height)
            return CGRect(
                x: availableRect.midX - side / 2,
                y: availableRect.midY - side / 2,
                width: side,
                height: side
            )
        }

        return availableRect
    }

    nonisolated private static func shapePath(for shape: ShapeOption, in rect: CGRect) -> UIBezierPath {
        switch shape {
        case .circle:
            return UIBezierPath(ovalIn: rect)
        case .square:
            return UIBezierPath(
                roundedRect: rect,
                cornerRadius: min(rect.width, rect.height) * 0.11
            )
        }
    }

    nonisolated private static func translatedAspectFillRect(
        for imageSize: CGSize,
        in targetRect: CGRect,
        offsetUnit: CGSize
    ) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return targetRect
        }

        let scale = max(targetRect.width / imageSize.width, targetRect.height / imageSize.height) * cropOverscanScale
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let baseRect = CGRect(
            x: targetRect.midX - width / 2,
            y: targetRect.midY - height / 2,
            width: width,
            height: height
        )

        let maxX = max(0, (width - targetRect.width) / 2)
        let maxY = max(0, (height - targetRect.height) / 2)
        let clampedX = max(-1, min(1, offsetUnit.width))
        let clampedY = max(-1, min(1, offsetUnit.height))

        return baseRect.offsetBy(dx: clampedX * maxX, dy: clampedY * maxY)
    }

    nonisolated private static func backgroundColor(for option: BackgroundOption, format: ExportFormat) -> UIColor {
        switch option {
        case .transparent:
            return format == .png ? .clear : .white
        case .black:
            return UIColor(red: 11 / 255, green: 12 / 255, blue: 14 / 255, alpha: 1)
        case .white:
            return .white
        }
    }

    @MainActor
    private static func makeInput(from project: CutoutProject) throws -> CutoutExportInput {
        let sourceData = project.selectedObjectID.flatMap { project.candidateCutoutImageDataByID[$0] } ?? project.cutoutImageData

        return CutoutExportInput(
            projectName: project.name,
            selectedObjectTitle: project.selectedObject?.title ?? String(localized: "export.object_fallback"),
            sourceImageData: sourceData,
            shape: project.shape,
            colorMode: project.colorMode,
            background: project.background,
            clarity: project.clarity,
            cropOffsetUnit: project.cropOffsetUnit
        )
    }

    nonisolated private static func suggestedFilename(for input: CutoutExportInput, format: ExportFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"

        let baseName = input.projectName
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let objectName = input.selectedObjectTitle
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        return "\(baseName)-\(objectName)-\(formatter.string(from: .now)).\(format.rawValue)"
    }
}
