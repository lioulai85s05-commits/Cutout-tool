import SwiftUI
import UIKit

struct RecognitionView: View {
    @ObservedObject var project: CutoutProject
    @EnvironmentObject private var model: CutoutAppModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                topHeader
                stageCard
                candidateCard
                actionCard
            }
            .padding(20)
            .padding(.bottom, 34)
        }
        .background(AppTheme.shellBackground.ignoresSafeArea())
        .navigationTitle("recognition.nav_title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("recognition.skip") {
                    model.openEditor()
                }
                .foregroundStyle(AppTheme.accentDeep)
            }
        }
    }

    private var topHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            flowStrip

            Text("recognition.header.title")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.inkPrimary)

            Text("recognition.header.subtitle")
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)
        }
        .padding(22)
        .surfaceCard()
    }

    private var stageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("recognition.stage.title", systemImage: "viewfinder")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.92))
                Spacer()
                statusPill(title: "\(project.detectedObjects.count) found", selected: true)
            }

            RecognitionStagePreview(project: project)
                .frame(height: 420)
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [AppTheme.canvasElevated, AppTheme.canvasDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 16)
    }

    private var candidateCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("recognition.detected.heading")
                    .font(.headline)
                    .foregroundStyle(AppTheme.inkPrimary)
            }

            ForEach(project.detectedObjects) { candidate in
                Button {
                    project.selectDetectedObject(candidate)
                } label: {
                    DetectionCandidateRow(
                        candidate: candidate,
                        isSelected: project.selectedObjectID == candidate.id,
                        thumbnail: project.cutoutUIImage(for: candidate)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(22)
        .surfaceCard()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("recognition.next.heading")
                .font(.headline)
                .foregroundStyle(AppTheme.inkPrimary)

            Text("recognition.next.subtitle")
                .font(.subheadline)
                .foregroundStyle(AppTheme.inkSecondary)

            Button {
                model.openEditor()
            } label: {
                HStack {
                    Text("recognition.next.cta")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .padding(22)
        .surfaceCard()
    }

    private var flowStrip: some View {
        HStack(spacing: 8) {
            flowPill("workflow.upload", active: false)
            flowPill("workflow.recognize", active: true)
            flowPill("workflow.select", active: true)
            flowPill("workflow.extract", active: false)
            flowPill("workflow.save", active: false)
        }
    }

    private func flowPill(_ title: LocalizedStringKey, active: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(active ? AppTheme.accentDeep : AppTheme.inkSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(active ? AppTheme.accentSoft : AppTheme.shellSurfaceStrong)
            .clipShape(Capsule())
    }

    private func statusPill(title: String, selected: Bool) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(selected ? Color.white : .white.opacity(0.76))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(selected ? AppTheme.accent.opacity(0.92) : .white.opacity(0.08))
            .clipShape(Capsule())
    }
}

private struct RecognitionStagePreview: View {
    @ObservedObject var project: CutoutProject

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.05))

            Circle()
                .fill(AppTheme.accent.opacity(0.18))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: 90, y: -110)

            if let image = project.originalUIImage {
                GeometryReader { proxy in
                    let fittedFrame = aspectFitFrame(imageSize: image.size, in: proxy.size)

                    ZStack(alignment: .topLeading) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: fittedFrame.width, height: fittedFrame.height)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .position(x: fittedFrame.midX, y: fittedFrame.midY)

                        ForEach(project.detectedObjects) { candidate in
                            detectionOverlay(for: candidate, in: fittedFrame)
                        }
                    }
                }
                .padding(16)
            } else {
                ContentUnavailableView("recognition.no_image", systemImage: "photo")
                    .foregroundStyle(.white)
            }

            VStack {
                HStack { Spacer() }
                Spacer()
                HStack {
                    Spacer()
                    confidenceBadge
                }
            }
            .padding(22)
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    @ViewBuilder
    private func detectionOverlay(for candidate: DetectionCandidate, in fittedFrame: CGRect) -> some View {
        let rect = CGRect(
            x: fittedFrame.minX + candidate.normalizedRect.minX * fittedFrame.width,
            y: fittedFrame.minY + candidate.normalizedRect.minY * fittedFrame.height,
            width: candidate.normalizedRect.width * fittedFrame.width,
            height: candidate.normalizedRect.height * fittedFrame.height
        )
        let isSelected = project.selectedObjectID == candidate.id
        let strokeColor = outlineColor(for: candidate, selected: isSelected)
        let contour = denormalizedContour(for: candidate, in: fittedFrame)
        let contourPath = contourPath(for: contour)
        contourPath
            .fill((isSelected ? AppTheme.accent.opacity(0.16) : Color.white.opacity(0.05)))
            .contentShape(contourPath)
            .onTapGesture {
                project.selectDetectedObject(candidate)
            }

        contourPath
            .stroke(strokeColor, style: StrokeStyle(lineWidth: isSelected ? 4 : 2.5, dash: isSelected ? [] : [8, 8]))
            .shadow(color: isSelected ? AppTheme.accent.opacity(0.4) : .clear, radius: 14, x: 0, y: 0)
            .allowsHitTesting(false)

        RoundedRectangle(cornerRadius: isSelected ? 26 : 20, style: .continuous)
            .strokeBorder(strokeColor.opacity(0.18), lineWidth: isSelected ? 1.2 : 0.8)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }

    private var confidenceBadge: some View {
        Text(project.selectedObject?.confidenceText ?? "--")
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.inkPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.shellSurfaceStrong)
            .clipShape(Capsule())
    }

    private func aspectFitFrame(imageSize: CGSize, in available: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(origin: .zero, size: available)
        }
        let scale = min(available.width / imageSize.width, available.height / imageSize.height)
        let width = imageSize.width * scale
        let height = imageSize.height * scale
        let originX = (available.width - width) / 2
        let originY = (available.height - height) / 2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    private func outlineColor(for candidate: DetectionCandidate, selected: Bool) -> Color {
        if selected {
            return AppTheme.accent
        }
        switch candidate.tintIndex % 3 {
        case 1:
            return AppTheme.accentSoft
        case 2:
            return Color.white.opacity(0.72)
        default:
            return AppTheme.borderSoft
        }
    }

    private func denormalizedContour(for candidate: DetectionCandidate, in fittedFrame: CGRect) -> [CGPoint] {
        candidate.normalizedContour.map { point in
            CGPoint(
                x: fittedFrame.minX + point.x * fittedFrame.width,
                y: fittedFrame.minY + point.y * fittedFrame.height
            )
        }
    }

    private func contourPath(for points: [CGPoint]) -> Path {
        guard let first = points.first else {
            return Path()
        }

        var path = Path()
        path.move(to: first)

        if points.count == 2 {
            path.addLine(to: points[1])
            return path
        }

        for index in 0..<points.count {
            let current = points[index]
            let next = points[(index + 1) % points.count]
            let midpoint = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
            path.addQuadCurve(to: midpoint, control: current)
        }

        path.closeSubpath()
        return path
    }
}

private struct DetectionCandidateRow: View {
    let candidate: DetectionCandidate
    let isSelected: Bool
    let thumbnail: UIImage?

    var body: some View {
        HStack(spacing: 14) {
            thumbnailView

            VStack(alignment: .leading, spacing: 4) {
                Text(candidate.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.inkPrimary)
                Text(candidate.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.inkSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(candidate.confidenceText)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isSelected ? AppTheme.accentDeep : AppTheme.inkPrimary)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppTheme.accent : AppTheme.borderSoft)
            }
        }
        .padding(16)
        .background(rowBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? AppTheme.accent.opacity(0.9) : AppTheme.borderSoft.opacity(0.7), lineWidth: isSelected ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var thumbnailView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.canvasDark)
                .frame(width: 58, height: 58)

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 58, height: 58)

                Image(systemName: candidate.symbolName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : AppTheme.accentDeep)
            }
        }
    }

    private var rowBackground: some ShapeStyle {
        isSelected ? AnyShapeStyle(AppTheme.accentSoft.opacity(0.42)) : AnyShapeStyle(AppTheme.shellSurfaceStrong)
    }

    private var iconBackground: some ShapeStyle {
        isSelected
            ? AnyShapeStyle(LinearGradient(colors: [AppTheme.accent, AppTheme.accentDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
            : AnyShapeStyle(AppTheme.shellSurface)
    }
}
