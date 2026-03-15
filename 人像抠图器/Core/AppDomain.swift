import Combine
import Foundation
import UIKit

enum AppRoute: Hashable, Sendable {
    case recognition
    case editor
    case settings
}

struct DetectionCandidate: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let confidence: Double
    let symbolName: String
    let tintIndex: Int
    let normalizedRect: CGRect
    let normalizedContour: [CGPoint]

    nonisolated init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        confidence: Double,
        symbolName: String,
        tintIndex: Int = 0,
        normalizedRect: CGRect = CGRect(x: 0.2, y: 0.18, width: 0.58, height: 0.64),
        normalizedContour: [CGPoint]? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.confidence = confidence
        self.symbolName = symbolName
        self.tintIndex = tintIndex
        self.normalizedRect = normalizedRect
        self.normalizedContour = normalizedContour ?? DetectionCandidate.contour(from: normalizedRect)
    }

    nonisolated var confidenceText: String {
        "\(Int(confidence * 100))%"
    }

    nonisolated static func primarySubject(confidence: Double = 0.96) -> DetectionCandidate {
        DetectionCandidate(
            title: NSLocalizedString("detection.primary_subject", comment: ""),
            subtitle: NSLocalizedString("detection.primary_subject.best_match_subtitle", comment: ""),
            confidence: confidence,
            symbolName: "scope",
            tintIndex: 0,
            normalizedRect: CGRect(x: 0.2, y: 0.16, width: 0.56, height: 0.68),
            normalizedContour: [
                CGPoint(x: 0.33, y: 0.18),
                CGPoint(x: 0.56, y: 0.16),
                CGPoint(x: 0.68, y: 0.24),
                CGPoint(x: 0.71, y: 0.42),
                CGPoint(x: 0.66, y: 0.68),
                CGPoint(x: 0.52, y: 0.82),
                CGPoint(x: 0.34, y: 0.8),
                CGPoint(x: 0.26, y: 0.6),
                CGPoint(x: 0.24, y: 0.34),
            ]
        )
    }

    nonisolated private static func contour(from rect: CGRect) -> [CGPoint] {
        [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY),
        ]
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case english
    case simplifiedChinese
    case traditionalChinese
    case japanese
    case korean
    case spanish

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return NSLocalizedString("settings.language.system", comment: "")
        case .english:
            return NSLocalizedString("settings.language.english", comment: "")
        case .simplifiedChinese:
            return NSLocalizedString("settings.language.simplified_chinese", comment: "")
        case .traditionalChinese:
            return NSLocalizedString("settings.language.traditional_chinese", comment: "")
        case .japanese:
            return NSLocalizedString("settings.language.japanese", comment: "")
        case .korean:
            return NSLocalizedString("settings.language.korean", comment: "")
        case .spanish:
            return NSLocalizedString("settings.language.spanish", comment: "")
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system:
            return nil
        case .english:
            return "en"
        case .simplifiedChinese:
            return "zh-Hans"
        case .traditionalChinese:
            return "zh-Hant"
        case .japanese:
            return "ja"
        case .korean:
            return "ko"
        case .spanish:
            return "es"
        }
    }

    var locale: Locale {
        if let localeIdentifier {
            return Locale(identifier: localeIdentifier)
        }
        return .autoupdatingCurrent
    }
}

enum ShapeOption: String, CaseIterable, Identifiable, Sendable {
    case circle
    case square

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .circle:
            return "shape.circle"
        case .square:
            return "shape.square"
        }
    }

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }

    var symbolName: String {
        switch self {
        case .circle:
            return "circle"
        case .square:
            return "square"
        }
    }
}

enum ColorOption: String, CaseIterable, Identifiable, Sendable {
    case original
    case grayscale
    case blackWhite

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .original:
            return "color.original"
        case .grayscale:
            return "color.grayscale"
        case .blackWhite:
            return "color.black_white"
        }
    }

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }
}

enum BackgroundOption: String, CaseIterable, Identifiable, Sendable {
    case transparent
    case black
    case white

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .transparent:
            return "background.transparent"
        case .black:
            return "background.black"
        case .white:
            return "background.white"
        }
    }

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }
}

enum ClarityOption: String, CaseIterable, Identifiable, Sendable {
    case soft
    case standard
    case sharp

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .soft:
            return "clarity.soft"
        case .standard:
            return "clarity.standard"
        case .sharp:
            return "clarity.sharp"
        }
    }

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }

    var subtitleKey: String {
        switch self {
        case .soft:
            return "clarity.soft.subtitle"
        case .standard:
            return "clarity.standard.subtitle"
        case .sharp:
            return "clarity.sharp.subtitle"
        }
    }

    var subtitle: String {
        NSLocalizedString(subtitleKey, comment: "")
    }
}

enum ExportFormat: String, CaseIterable, Identifiable, Sendable {
    case png
    case jpg

    var id: String { rawValue }

    var title: String {
        rawValue.uppercased()
    }
}

enum ResolutionOption: String, CaseIterable, Identifiable, Sendable {
    case standard
    case high

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .standard:
            return "resolution.standard"
        case .high:
            return "resolution.high"
        }
    }

    var title: String {
        NSLocalizedString(titleKey, comment: "")
    }

    var subtitleKey: String {
        switch self {
        case .standard:
            return "resolution.standard.subtitle"
        case .high:
            return "resolution.high.subtitle"
        }
    }

    var subtitle: String {
        NSLocalizedString(subtitleKey, comment: "")
    }
}

struct ProcessingSnapshot {
    let progress: Double
    let stageTitle: String
    let detail: String
    let imageData: Data?
}

struct ProcessingStageUpdate: Sendable {
    let progress: Double
    let title: String
    let detail: String
}

struct DetectedObjectOutput: Sendable {
    let candidate: DetectionCandidate
    let cutoutImageData: Data
}

struct CutoutProcessingOutput: Sendable {
    let originalImageData: Data
    let cutoutImageData: Data
    let detectedObjects: [DetectedObjectOutput]
}

@MainActor
final class CutoutProject: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let createdAt: Date
    let originalImageData: Data
    let cutoutImageData: Data
    let candidateCutoutImageDataByID: [DetectionCandidate.ID: Data]

    @Published var detectedObjects: [DetectionCandidate]
    @Published var selectedObjectID: DetectionCandidate.ID?
    @Published var shape: ShapeOption
    @Published var colorMode: ColorOption
    @Published var background: BackgroundOption
    @Published var clarity: ClarityOption
    @Published var cropOffsetUnit: CGSize
    @Published var highPrecisionEnabled: Bool

    init(
        name: String,
        originalImageData: Data,
        cutoutImageData: Data,
        detectedObjectOutputs: [DetectedObjectOutput] = [],
        createdAt: Date = .now,
        shape: ShapeOption = .circle,
        colorMode: ColorOption = .original,
        background: BackgroundOption = .transparent,
        clarity: ClarityOption = .standard,
        cropOffsetUnit: CGSize = .zero,
        highPrecisionEnabled: Bool = false
    ) {
        self.name = name
        self.originalImageData = originalImageData
        self.cutoutImageData = cutoutImageData
        self.createdAt = createdAt
        let normalizedOutputs = detectedObjectOutputs.isEmpty
            ? [DetectedObjectOutput(candidate: DetectionCandidate.primarySubject(), cutoutImageData: cutoutImageData)]
            : detectedObjectOutputs
        let normalizedObjects = normalizedOutputs.map(\.candidate)
        self.detectedObjects = normalizedObjects
        self.selectedObjectID = normalizedObjects.first?.id
        self.candidateCutoutImageDataByID = Dictionary(uniqueKeysWithValues: normalizedOutputs.map { ($0.candidate.id, $0.cutoutImageData) })
        self.shape = shape
        self.colorMode = colorMode
        self.background = background
        self.clarity = clarity
        self.cropOffsetUnit = cropOffsetUnit
        self.highPrecisionEnabled = highPrecisionEnabled
    }

    var originalUIImage: UIImage? {
        UIImage(data: originalImageData)
    }

    var cutoutUIImage: UIImage? {
        if let selectedObjectID, let data = candidateCutoutImageDataByID[selectedObjectID] {
            return UIImage(data: data)
        }
        return UIImage(data: cutoutImageData)
    }

    func cutoutUIImage(for candidate: DetectionCandidate) -> UIImage? {
        guard let data = candidateCutoutImageDataByID[candidate.id] else {
            return nil
        }
        return UIImage(data: data)
    }

    var uiImage: UIImage? {
        cutoutUIImage ?? originalUIImage
    }

    var createdAtText: String {
        Self.formatter.string(from: createdAt)
    }

    var selectedObject: DetectionCandidate? {
        guard let selectedObjectID else {
            return detectedObjects.first
        }
        return detectedObjects.first(where: { $0.id == selectedObjectID }) ?? detectedObjects.first
    }

    func selectDetectedObject(_ candidate: DetectionCandidate) {
        selectedObjectID = candidate.id
        cropOffsetUnit = .zero
    }

    func resetEditing() {
        shape = .circle
        colorMode = .original
        background = .transparent
        clarity = .standard
        cropOffsetUnit = .zero
        highPrecisionEnabled = false
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
