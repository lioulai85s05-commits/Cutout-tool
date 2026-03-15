import SwiftUI
import UIKit

private enum EditorTool: String, CaseIterable, Identifiable {
    case shape
    case color
    case background
    case clarity
    case advanced

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .shape:
            return "editor.tool.shape"
        case .color:
            return "editor.tool.color"
        case .background:
            return "editor.tool.background"
        case .clarity:
            return "editor.tool.clarity"
        case .advanced:
            return "editor.tool.advanced"
        }
    }

    var symbolName: String {
        switch self {
        case .shape:
            return "circle.square"
        case .color:
            return "paintpalette.fill"
        case .background:
            return "square.on.square"
        case .clarity:
            return "sparkles"
        case .advanced:
            return "scope"
        }
    }
}

struct EditorView: View {
    @ObservedObject var project: CutoutProject
    @EnvironmentObject private var model: CutoutAppModel
    @EnvironmentObject private var purchaseStore: PurchaseStore

    @State private var activeTool: EditorTool = .shape
    @State private var showOriginal = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                objectSwitcherCard
                previewCard
                toolRail
                activePanel
                exportCard
            }
            .padding(20)
            .padding(.bottom, 34)
        }
        .background(AppTheme.shellBackground.ignoresSafeArea())
        .navigationTitle("editor.nav_title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("editor.buy_once") {
                    model.openPaywall()
                }
                .foregroundStyle(AppTheme.accentDeep)

                Button("editor.export") {
                    model.openExport()
                }
                .foregroundStyle(AppTheme.accentDeep)
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(project.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.inkPrimary)

                    Text("editor.hero.subtitle")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.inkSecondary)

                    Text(project.createdAtText)
                        .font(.caption)
                        .foregroundStyle(AppTheme.inkSecondary)
                }

                Spacer()

                SelectedObjectBadge(candidate: project.selectedObject)
            }

            HStack {
                HStack(spacing: 8) {
                    editorPill("editor.state.recognized", active: true)
                    editorPill("editor.state.editing", active: true)
                    editorPill("editor.state.export", active: false)
                }

                Spacer()

                Button("editor.change_object") {
                    model.openRecognition()
                }
                .buttonStyle(.plain)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accentDeep)
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var objectSwitcherCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("editor.detected.heading")
                    .font(.headline)
                    .foregroundStyle(AppTheme.inkPrimary)
                Spacer()
                Text("\(project.detectedObjects.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.inkSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(project.detectedObjects) { candidate in
                        Button {
                            project.selectDetectedObject(candidate)
                        } label: {
                            EditorObjectChip(
                                candidate: candidate,
                                image: project.cutoutUIImage(for: candidate),
                                isSelected: project.selectedObjectID == candidate.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("editor.preview.heading")
                        .font(.headline)
                        .foregroundStyle(AppTheme.inkPrimary)
                    Text("editor.preview.subtitle")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.inkSecondary)
                }

                Spacer()

                Picker("editor.preview.mode", selection: $showOriginal) {
                    Text("editor.preview.cutout").tag(false)
                    Text("editor.preview.original").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)
            }

            CutoutPreviewCanvas(project: project, showOriginal: showOriginal)
                .frame(height: 460)
        }
        .padding(22)
        .surfaceCard()
    }

    private var toolRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(EditorTool.allCases) { tool in
                    Button {
                        activeTool = tool
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: tool.symbolName)
                            Text(tool.titleKey)
                        }
                    }
                    .buttonStyle(ToolChipStyle(selected: activeTool == tool))
                }
            }
        }
    }

    @ViewBuilder
    private var activePanel: some View {
        switch activeTool {
        case .shape:
            optionGridPanel(
                columns: 2,
                title: "editor.shape.heading",
                subtitle: "editor.shape.subtitle"
            ) {
                ForEach(ShapeOption.allCases) { option in
                    Button {
                        project.shape = option
                    } label: {
                        Label {
                            Text(LocalizedStringKey(option.titleKey))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        } icon: {
                            Image(systemName: option.symbolName)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ToolChipStyle(selected: project.shape == option))
                }
            }
        case .color:
            optionGridPanel(
                columns: 3,
                title: "editor.color.heading",
                subtitle: "editor.color.subtitle"
            ) {
                ForEach(ColorOption.allCases) { option in
                    Button {
                        project.colorMode = option
                    } label: {
                        Text(LocalizedStringKey(option.titleKey))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ToolChipStyle(selected: project.colorMode == option))
                }
            }
        case .background:
            optionGridPanel(
                columns: 3,
                title: "editor.background.heading",
                subtitle: "editor.background.subtitle"
            ) {
                ForEach(BackgroundOption.allCases) { option in
                    Button {
                        project.background = option
                    } label: {
                        Text(LocalizedStringKey(option.titleKey))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ToolChipStyle(selected: project.background == option))
                }
            }
        case .clarity:
            optionGridPanel(
                columns: 3,
                title: "editor.clarity.heading",
                subtitle: LocalizedStringKey(project.clarity.subtitleKey)
            ) {
                    ForEach(ClarityOption.allCases) { option in
                        Button {
                            project.clarity = option
                        } label: {
                            Text(LocalizedStringKey(option.titleKey))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ToolChipStyle(selected: project.clarity == option))
                    }
            }
        case .advanced:
            VStack(alignment: .leading, spacing: 16) {
                Text("editor.advanced.heading")
                    .font(.headline)
                    .foregroundStyle(AppTheme.inkPrimary)

                Toggle(isOn: $project.highPrecisionEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("editor.advanced.high_precision")
                            .font(.headline)
                            .foregroundStyle(AppTheme.inkPrimary)
                        Text("editor.advanced.subtitle")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.inkSecondary)
                    }
                }
                .toggleStyle(.switch)
                .disabled(!purchaseStore.hasLifetimeAccess)

                if purchaseStore.hasLifetimeAccess {
                    Label("editor.advanced.unlocked", systemImage: "checkmark.seal.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accentDeep)
                } else {
                    Button("editor.advanced.see_buy_once") {
                        model.openPaywall()
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            }
            .padding(22)
            .surfaceCard()
        }
    }

    private var exportCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("editor.export_card.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            Text("editor.export_card.subtitle")
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)

            HStack(spacing: 12) {
                Button("editor.reset") {
                    model.resetCurrentProject()
                }
                .buttonStyle(SecondaryActionButtonStyle())

                Button {
                    model.openExport()
                } label: {
                    HStack {
                        Text("editor.open_export")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private func editorPill(_ title: LocalizedStringKey, active: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(active ? AppTheme.accentDeep : AppTheme.inkSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(active ? AppTheme.accentSoft : AppTheme.shellSurfaceStrong)
            .clipShape(Capsule())
    }

    private func optionGridPanel<Content: View>(
        columns: Int,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)

            OptionGrid(columns: columns, spacing: 10) {
                content()
            }
        }
        .padding(22)
        .surfaceCard()
    }
}

private struct SelectedObjectBadge: View {
    let candidate: DetectionCandidate?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("editor.selected")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.inkSecondary)

            HStack(spacing: 8) {
                Image(systemName: candidate?.symbolName ?? "scope")
                Text(candidate?.title ?? String(localized: "editor.primary_subject"))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.inkPrimary)

            Text(candidate?.confidenceText ?? "--")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.accentDeep)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.shellSurfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct EditorObjectChip: View {
    let candidate: DetectionCandidate
    let image: UIImage?
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? AppTheme.canvasElevated : AppTheme.canvasDark)
                    .frame(width: 96, height: 86)

                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 70)
                } else {
                    Image(systemName: candidate.symbolName)
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }

            Text(candidate.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.inkPrimary)
                .lineLimit(1)

            Text(candidate.confidenceText)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? AppTheme.accentDeep : AppTheme.inkSecondary)
        }
        .padding(12)
        .frame(width: 122, alignment: .leading)
        .background(isSelected ? AppTheme.accentSoft.opacity(0.5) : AppTheme.shellSurfaceStrong)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? AppTheme.accent.opacity(0.9) : AppTheme.borderSoft.opacity(0.7), lineWidth: isSelected ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct CutoutPreviewCanvas: View {
    @ObservedObject var project: CutoutProject
    let showOriginal: Bool

    var body: some View {
        ZStack {
            canvasBackground
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

            Circle()
                .fill(AppTheme.accent.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 48)
                .offset(x: 110, y: -120)

            if let image = previewUIImage {
                previewImage(image)
                    .padding(showOriginal ? 12 : 20)
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 42))
                        .foregroundStyle(.white.opacity(0.78))
                    Text("editor.no_preview")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
        }
        .overlay(alignment: .topLeading) {
            Text(showOriginal ? "editor.preview.original_overlay" : "editor.preview.current_cutout")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.84))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.28))
                .clipShape(Capsule())
                .padding(16)
        }
    }

    private var previewUIImage: UIImage? {
        if showOriginal {
            return project.originalUIImage
        }
        return project.cutoutUIImage ?? project.originalUIImage
    }

    @ViewBuilder
    private var canvasBackground: some View {
        switch project.background {
        case .transparent:
            CheckerboardView()
        case .black:
            AppTheme.canvasDark
        case .white:
            Color.white
        }
    }

    @ViewBuilder
    private func previewImage(_ image: UIImage) -> some View {
        if showOriginal {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        } else {
            InteractiveCropPreview(project: project, image: image)
        }
    }
}

private struct ColorModeModifier: ViewModifier {
    let mode: ColorOption
    let clarity: ClarityOption

    func body(content: Content) -> some View {
        switch mode {
        case .original:
            content
                .contrast(clarityContrast)
                .saturation(1.0)
        case .grayscale:
            content
                .saturation(0)
                .contrast(clarityContrast)
        case .blackWhite:
            content
                .saturation(0)
                .contrast(clarityContrast + 0.25)
                .brightness(0.03)
        }
    }

    private var clarityContrast: Double {
        switch clarity {
        case .soft:
            return 0.94
        case .standard:
            return 1.04
        case .sharp:
            return 1.16
        }
    }
}

private struct CheckerboardView: View {
    let cellSize: CGFloat = 18

    var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / cellSize))
            let rows = Int(ceil(size.height / cellSize))

            for row in 0..<rows {
                for column in 0..<columns {
                    let rect = CGRect(
                        x: CGFloat(column) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    let color = (row + column).isMultiple(of: 2) ? AppTheme.checkerLight : AppTheme.checkerDark
                    context.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
}

private struct InteractiveCropPreview: View {
    private let cropOverscanScale: CGFloat = 1.28

    @ObservedObject var project: CutoutProject
    let image: UIImage

    @State private var dragOrigin: CGSize?

    var body: some View {
        GeometryReader { proxy in
            let outerRect = CGRect(origin: .zero, size: proxy.size)
            let cropRect = cropRect(in: outerRect)
            let drawRect = translatedAspectFillRect(
                for: image.size,
                in: cropRect,
                offsetUnit: project.cropOffsetUnit
            )
            let cropPath = cropPath(in: cropRect)

            ZStack {
                if project.background != .transparent {
                    cropPath
                        .fill(fillColor)
                }

                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .modifier(ColorModeModifier(mode: project.colorMode, clarity: project.clarity))
                    .frame(width: drawRect.width, height: drawRect.height)
                    .position(x: drawRect.midX, y: drawRect.midY)
            }
            .mask(cropPath.fill(style: FillStyle()))
            .overlay {
                cropPath
                    .stroke(project.background == .transparent ? AppTheme.borderSoft.opacity(0.85) : Color.white.opacity(0.14), lineWidth: 1.2)
            }
            .overlay {
                CropGestureSurface(
                    shape: project.shape,
                    cropRect: cropRect,
                    dragGesture: dragGesture(for: image.size, in: cropRect)
                )
            }
        }
        .padding(project.shape == .circle ? 18 : 12)
    }

    private var fillColor: Color {
        switch project.background {
        case .transparent:
            return .clear
        case .black:
            return AppTheme.canvasDark
        case .white:
            return .white
        }
    }

    private func cropRect(in outerRect: CGRect) -> CGRect {
        let inset = project.shape == .circle ? 18.0 : 12.0
        let available = outerRect.insetBy(dx: inset, dy: inset)

        if project.shape == .circle {
            let side = min(available.width, available.height)
            return CGRect(
                x: available.midX - side / 2,
                y: available.midY - side / 2,
                width: side,
                height: side
            )
        }

        return available
    }

    private func cropPath(in rect: CGRect) -> Path {
        switch project.shape {
        case .circle:
            return Path(ellipseIn: rect)
        case .square:
            return RoundedRectangle(cornerRadius: 32, style: .continuous)
                .path(in: rect)
        }
    }

    private func translatedAspectFillRect(
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
        let maxTravel = maxTravel(for: baseRect.size, in: targetRect.size)

        return baseRect.offsetBy(
            dx: max(-1, min(1, offsetUnit.width)) * maxTravel.width,
            dy: max(-1, min(1, offsetUnit.height)) * maxTravel.height
        )
    }

    private func maxTravel(for imageSize: CGSize, in cropSize: CGSize) -> CGSize {
        CGSize(
            width: max(0, (imageSize.width - cropSize.width) / 2),
            height: max(0, (imageSize.height - cropSize.height) / 2)
        )
    }

    private func dragGesture(for imageSize: CGSize, in cropRect: CGRect) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let baseRect = translatedAspectFillRect(for: imageSize, in: cropRect, offsetUnit: .zero)
                let maxTravel = maxTravel(for: baseRect.size, in: cropRect.size)

                if dragOrigin == nil {
                    dragOrigin = CGSize(
                        width: project.cropOffsetUnit.width * maxTravel.width,
                        height: project.cropOffsetUnit.height * maxTravel.height
                    )
                }

                let origin = dragOrigin ?? .zero
                let proposed = CGSize(
                    width: origin.width + value.translation.width,
                    height: origin.height + value.translation.height
                )

                project.cropOffsetUnit = CGSize(
                    width: normalizedOffsetValue(proposed.width, maxTravel: maxTravel.width),
                    height: normalizedOffsetValue(proposed.height, maxTravel: maxTravel.height)
                )
            }
            .onEnded { _ in
                dragOrigin = nil
            }
    }

    private func normalizedOffsetValue(_ value: CGFloat, maxTravel: CGFloat) -> CGFloat {
        guard maxTravel > 0 else {
            return 0
        }
        return max(-1, min(1, value / maxTravel))
    }
}

private struct CropGestureSurface<GestureType: Gesture>: View {
    let shape: ShapeOption
    let cropRect: CGRect
    let dragGesture: GestureType

    var body: some View {
        Group {
            switch shape {
            case .circle:
                Circle()
                    .fill(Color.white.opacity(0.001))
                    .frame(width: cropRect.width, height: cropRect.height)
            case .square:
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.white.opacity(0.001))
                    .frame(width: cropRect.width, height: cropRect.height)
            }
        }
        .position(x: cropRect.midX, y: cropRect.midY)
        .gesture(dragGesture)
    }
}

private struct OptionGrid<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(columns: Int, spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: spacing, alignment: .leading), count: columns),
            alignment: .leading,
            spacing: spacing
        ) {
            content
        }
    }
}
