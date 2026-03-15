import CoreImage
import Foundation
import UIKit
import Vision

protocol PortraitCutoutProcessing {
    func process(
        imageData: Data,
        reportProgress: @escaping (ProcessingStageUpdate) async -> Void
    ) async throws -> CutoutProcessingOutput
}

enum PortraitCutoutError: LocalizedError {
    case invalidImageData
    case subjectNotFound
    case renderFailed

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return NSLocalizedString("processing.error.invalid_image", comment: "")
        case .subjectNotFound:
            return NSLocalizedString("processing.error.subject_not_found", comment: "")
        case .renderFailed:
            return NSLocalizedString("processing.error.render_failed", comment: "")
        }
    }
}

struct LocalVisionPortraitCutoutProcessor: PortraitCutoutProcessing {
    nonisolated init() {}

    nonisolated func process(
        imageData: Data,
        reportProgress: @escaping (ProcessingStageUpdate) async -> Void
    ) async throws -> CutoutProcessingOutput {
        await reportProgress(
            ProcessingStageUpdate(
                progress: 0.10,
                title: NSLocalizedString("processing.stage.loading.title", comment: ""),
                detail: NSLocalizedString("processing.stage.loading.detail", comment: "")
            )
        )

        try await Task.sleep(nanoseconds: 80_000_000)

        await reportProgress(
            ProcessingStageUpdate(
                progress: 0.34,
                title: NSLocalizedString("processing.stage.detecting.title", comment: ""),
                detail: NSLocalizedString("processing.stage.detecting.detail", comment: "")
            )
        )

        let output = try await Task.detached(priority: .userInitiated) {
            try Self.performCutout(imageData: imageData)
        }.value

        await reportProgress(
            ProcessingStageUpdate(
                progress: 0.82,
                title: NSLocalizedString("processing.stage.refining.title", comment: ""),
                detail: NSLocalizedString("processing.stage.refining.detail", comment: "")
            )
        )

        try await Task.sleep(nanoseconds: 60_000_000)

        await reportProgress(
            ProcessingStageUpdate(
                progress: 1.0,
                title: NSLocalizedString("processing.stage.opening.title", comment: ""),
                detail: NSLocalizedString("processing.stage.opening.detail", comment: "")
            )
        )

        return output
    }

    nonisolated private static func performCutout(imageData: Data) throws -> CutoutProcessingOutput {
        guard let sourceImage = UIImage(data: imageData) else {
            throw PortraitCutoutError.invalidImageData
        }

        let normalizedImage = sourceImage.normalizedForProcessing()
        guard let normalizedData = normalizedImage.pngData() else {
            throw PortraitCutoutError.invalidImageData
        }

        guard let ciImage = CIImage(data: normalizedData) else {
            throw PortraitCutoutError.invalidImageData
        }

        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        let observation = try firstObservation(using: requestHandler)

        let maskedPixelBuffer = try observation.generateMaskedImage(
            ofInstances: observation.allInstances,
            from: requestHandler,
            croppedToInstancesExtent: false
        )

        let context = CIContext(options: nil)
        let outputImage = CIImage(cvPixelBuffer: maskedPixelBuffer).cropped(to: ciImage.extent)
        let detectedObjects = try makeDetectedObjects(
            from: observation,
            requestHandler: requestHandler,
            sourceImage: ciImage,
            context: context,
            imageScale: normalizedImage.scale
        )

        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            throw PortraitCutoutError.renderFailed
        }

        let resultImage = UIImage(cgImage: cgImage, scale: normalizedImage.scale, orientation: .up)
        guard let combinedCutoutData = resultImage.pngData() else {
            throw PortraitCutoutError.renderFailed
        }

        let primaryCutoutData = detectedObjects.first?.cutoutImageData ?? combinedCutoutData

        return CutoutProcessingOutput(
            originalImageData: normalizedData,
            cutoutImageData: primaryCutoutData,
            detectedObjects: detectedObjects
        )
    }

    nonisolated private static func firstObservation(using requestHandler: VNImageRequestHandler) throws -> VNInstanceMaskObservation {
        let foregroundRequest = VNGenerateForegroundInstanceMaskRequest()
        try requestHandler.perform([foregroundRequest])

        if let observation = foregroundRequest.results?.first, !observation.allInstances.isEmpty {
            return observation
        }

        let personRequest = VNGeneratePersonInstanceMaskRequest()
        try requestHandler.perform([personRequest])

        if let observation = personRequest.results?.first, !observation.allInstances.isEmpty {
            return observation
        }

        throw PortraitCutoutError.subjectNotFound
    }

    nonisolated private static func makeDetectedObjects(
        from observation: VNInstanceMaskObservation,
        requestHandler: VNImageRequestHandler,
        sourceImage: CIImage,
        context: CIContext,
        imageScale: CGFloat
    ) throws -> [DetectedObjectOutput] {
        let instanceIDs = Array(observation.allInstances)
        var rankedObjects: [(area: Int, output: DetectedObjectOutput)] = []

        for (index, instanceID) in instanceIDs.enumerated() {
            let instanceSet = IndexSet(integer: instanceID)
            let mask = try observation.generateMask(forInstances: instanceSet)
            let descriptor = try analyzeMask(mask)

            guard descriptor.area > 0 else {
                continue
            }

            let maskedPixelBuffer = try observation.generateMaskedImage(
                ofInstances: instanceSet,
                from: requestHandler,
                croppedToInstancesExtent: false
            )
            let maskedImage = CIImage(cvPixelBuffer: maskedPixelBuffer).cropped(to: sourceImage.extent)

            guard let cgImage = context.createCGImage(maskedImage, from: maskedImage.extent) else {
                continue
            }

            let uiImage = UIImage(cgImage: cgImage, scale: imageScale, orientation: .up)
            guard let cutoutData = uiImage.pngData() else {
                continue
            }

            let candidate = DetectionCandidate(
                title: localizedObjectTitle(for: index),
                subtitle: localizedObjectSubtitle(for: index),
                confidence: descriptor.confidence,
                symbolName: index == 0 ? "scope" : "sparkles.rectangle.stack",
                tintIndex: index,
                normalizedRect: descriptor.boundingBox,
                normalizedContour: descriptor.contour
            )

            rankedObjects.append((descriptor.area, DetectedObjectOutput(candidate: candidate, cutoutImageData: cutoutData)))
        }

        let sorted = rankedObjects.sorted { lhs, rhs in
            lhs.area > rhs.area
        }

        if sorted.isEmpty {
            return [DetectedObjectOutput(candidate: DetectionCandidate.primarySubject(), cutoutImageData: Data())].filter { !$0.cutoutImageData.isEmpty }
        }

        return sorted.enumerated().map { index, element in
            let candidate = DetectionCandidate(
                id: element.output.candidate.id,
                title: localizedObjectTitle(for: index),
                subtitle: localizedObjectSubtitle(for: index),
                confidence: element.output.candidate.confidence,
                symbolName: index == 0 ? "scope" : "sparkles.rectangle.stack",
                tintIndex: index,
                normalizedRect: element.output.candidate.normalizedRect,
                normalizedContour: element.output.candidate.normalizedContour
            )
            return DetectedObjectOutput(candidate: candidate, cutoutImageData: element.output.cutoutImageData)
        }
    }

    nonisolated private static func analyzeMask(_ pixelBuffer: CVPixelBuffer) throws -> MaskDescriptor {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw PortraitCutoutError.renderFailed
        }

        let floatBuffer = baseAddress.assumingMemoryBound(to: Float.self)
        let stride = bytesPerRow / MemoryLayout<Float>.stride
        let threshold: Float = 0.05

        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1
        var area = 0

        for y in 0..<height {
            let rowStart = y * stride
            for x in 0..<width {
                if floatBuffer[rowStart + x] > threshold {
                    area += 1
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }

        guard area > 0, maxX >= minX, maxY >= minY else {
            return MaskDescriptor.empty
        }

        let boundingBox = CGRect(
            x: CGFloat(minX) / CGFloat(width),
            y: CGFloat(minY) / CGFloat(height),
            width: CGFloat(maxX - minX + 1) / CGFloat(width),
            height: CGFloat(maxY - minY + 1) / CGFloat(height)
        )

        let contour = boundaryContour(
            floatBuffer: floatBuffer,
            stride: stride,
            width: width,
            height: height,
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY,
            threshold: threshold
        )

        let normalizedArea = Double(area) / Double(width * height)
        let confidence = max(0.56, min(0.97, 0.58 + normalizedArea * 2.2))

        return MaskDescriptor(
            boundingBox: boundingBox,
            contour: contour,
            area: area,
            confidence: confidence
        )
    }

    nonisolated private static func boundaryContour(
        floatBuffer: UnsafeMutablePointer<Float>,
        stride: Int,
        width: Int,
        height: Int,
        minX: Int,
        minY: Int,
        maxX: Int,
        maxY: Int,
        threshold: Float
    ) -> [CGPoint] {
        var boundaryPixels: [CGPoint] = []
        var centroidX = 0.0
        var centroidY = 0.0
        var foregroundCount = 0.0

        for y in minY...maxY {
            for x in minX...maxX {
                guard floatBuffer[(y * stride) + x] > threshold else {
                    continue
                }

                foregroundCount += 1
                centroidX += Double(x) + 0.5
                centroidY += Double(y) + 0.5

                if isBoundaryPixel(
                    x: x,
                    y: y,
                    floatBuffer: floatBuffer,
                    stride: stride,
                    width: width,
                    height: height,
                    threshold: threshold
                ) {
                    boundaryPixels.append(CGPoint(x: x, y: y))
                }
            }
        }

        guard !boundaryPixels.isEmpty, foregroundCount > 0 else {
            return [
                CGPoint(x: CGFloat(minX) / CGFloat(width), y: CGFloat(minY) / CGFloat(height)),
                CGPoint(x: CGFloat(maxX) / CGFloat(width), y: CGFloat(minY) / CGFloat(height)),
                CGPoint(x: CGFloat(maxX) / CGFloat(width), y: CGFloat(maxY) / CGFloat(height)),
                CGPoint(x: CGFloat(minX) / CGFloat(width), y: CGFloat(maxY) / CGFloat(height)),
            ]
        }

        let centroid = CGPoint(
            x: centroidX / foregroundCount,
            y: centroidY / foregroundCount
        )

        let targetPointCount = max(14, min(28, Int(Double(boundaryPixels.count).squareRoot() * 2.0)))
        var binnedPoints = Array<CGPoint?>(repeating: nil, count: targetPointCount)
        var binnedDistances = Array<Double>(repeating: -.greatestFiniteMagnitude, count: targetPointCount)

        for point in boundaryPixels {
            let centered = CGPoint(x: point.x + 0.5, y: point.y + 0.5)
            let dx = centered.x - centroid.x
            let dy = centered.y - centroid.y
            let angle = atan2(dy, dx)
            let normalizedAngle = angle < 0 ? angle + (.pi * 2) : angle
            let bin = min(targetPointCount - 1, Int((normalizedAngle / (.pi * 2)) * Double(targetPointCount)))
            let distance = sqrt((dx * dx) + (dy * dy))

            if distance > binnedDistances[bin] {
                binnedDistances[bin] = distance
                binnedPoints[bin] = centered
            }
        }

        let contour = binnedPoints.compactMap { $0 }.map { point in
            CGPoint(
                x: point.x / CGFloat(width),
                y: point.y / CGFloat(height)
            )
        }

        let deduped = deduplicated(points: contour)
        let smoothed = simplifyContour(
            points: smoothedClosedContour(points: deduped, iterations: 2),
            minimumDistance: 0.014
        )
        if smoothed.count >= 6 {
            return smoothed
        }
        if deduped.count >= 6 {
            return deduped
        }

        return [
            CGPoint(x: CGFloat(minX) / CGFloat(width), y: CGFloat(minY) / CGFloat(height)),
            CGPoint(x: CGFloat(maxX) / CGFloat(width), y: CGFloat(minY) / CGFloat(height)),
            CGPoint(x: CGFloat(maxX) / CGFloat(width), y: CGFloat(maxY) / CGFloat(height)),
            CGPoint(x: CGFloat(minX) / CGFloat(width), y: CGFloat(maxY) / CGFloat(height)),
        ]
    }

    nonisolated private static func isBoundaryPixel(
        x: Int,
        y: Int,
        floatBuffer: UnsafeMutablePointer<Float>,
        stride: Int,
        width: Int,
        height: Int,
        threshold: Float
    ) -> Bool {
        for offsetY in -1...1 {
            for offsetX in -1...1 {
                if offsetX == 0, offsetY == 0 {
                    continue
                }

                let neighborX = x + offsetX
                let neighborY = y + offsetY

                if neighborX < 0 || neighborX >= width || neighborY < 0 || neighborY >= height {
                    return true
                }

                if floatBuffer[(neighborY * stride) + neighborX] <= threshold {
                    return true
                }
            }
        }

        return false
    }

    nonisolated private static func deduplicated(points: [CGPoint]) -> [CGPoint] {
        var unique: [CGPoint] = []

        for point in points {
            if let last = unique.last, abs(last.x - point.x) < 0.0001, abs(last.y - point.y) < 0.0001 {
                continue
            }
            unique.append(point)
        }

        if let first = unique.first, let last = unique.last, abs(first.x - last.x) < 0.0001, abs(first.y - last.y) < 0.0001 {
            unique.removeLast()
        }

        return unique
    }

    nonisolated private static func smoothedClosedContour(points: [CGPoint], iterations: Int) -> [CGPoint] {
        guard points.count > 3 else {
            return points
        }

        var working = points

        for _ in 0..<iterations {
            var next: [CGPoint] = []

            for index in 0..<working.count {
                let current = working[index]
                let following = working[(index + 1) % working.count]

                let q = CGPoint(
                    x: current.x * 0.75 + following.x * 0.25,
                    y: current.y * 0.75 + following.y * 0.25
                )
                let r = CGPoint(
                    x: current.x * 0.25 + following.x * 0.75,
                    y: current.y * 0.25 + following.y * 0.75
                )

                next.append(q)
                next.append(r)
            }

            working = next
        }

        return working
    }

    nonisolated private static func simplifyContour(points: [CGPoint], minimumDistance: CGFloat) -> [CGPoint] {
        guard points.count > 3 else {
            return points
        }

        var simplified: [CGPoint] = []

        for point in points {
            guard let last = simplified.last else {
                simplified.append(point)
                continue
            }

            let dx = point.x - last.x
            let dy = point.y - last.y
            let distance = sqrt((dx * dx) + (dy * dy))

            if distance >= minimumDistance {
                simplified.append(point)
            }
        }

        if simplified.count > 2, let first = simplified.first, let last = simplified.last {
            let dx = first.x - last.x
            let dy = first.y - last.y
            if sqrt((dx * dx) + (dy * dy)) < minimumDistance {
                simplified.removeLast()
            }
        }

        return simplified
    }

    nonisolated private static func localizedObjectTitle(for index: Int) -> String {
        if index == 0 {
            return NSLocalizedString("detection.primary_subject", comment: "")
        }
        let format = NSLocalizedString("detection.object_format", comment: "")
        return String(format: format, index + 1)
    }

    nonisolated private static func localizedObjectSubtitle(for index: Int) -> String {
        if index == 0 {
            return NSLocalizedString("detection.primary_subject.subtitle", comment: "")
        }
        return NSLocalizedString("detection.object.subtitle", comment: "")
    }
}

nonisolated private extension UIImage {
    func normalizedForProcessing() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }

        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = scale
        rendererFormat.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

private struct MaskDescriptor {
    let boundingBox: CGRect
    let contour: [CGPoint]
    let area: Int
    let confidence: Double

    nonisolated static let empty = MaskDescriptor(boundingBox: .zero, contour: [], area: 0, confidence: 0)
}
