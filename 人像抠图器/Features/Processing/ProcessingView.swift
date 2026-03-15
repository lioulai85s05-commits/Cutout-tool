import SwiftUI
import UIKit

struct ProcessingView: View {
    @EnvironmentObject private var model: CutoutAppModel

    var body: some View {
        let snapshot = model.processingState

        ZStack {
            LinearGradient(
                colors: [AppTheme.canvasElevated, AppTheme.canvasDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppTheme.accent.opacity(0.18))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: 180, y: -220)

            VStack(spacing: 28) {
                Spacer(minLength: 18)

                if let image = snapshot?.imageData.flatMap(UIImage.init(data:)) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 220, maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        )
                }

                VStack(spacing: 10) {
                    Text(snapshot?.stageTitle ?? String(localized: "processing.preparing.title"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(snapshot?.detail ?? String(localized: "processing.preparing.subtitle"))
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    HStack {
                        Text("processing.progress")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int((snapshot?.progress ?? 0) * 100))%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    ProgressView(value: snapshot?.progress ?? 0)
                        .tint(AppTheme.accent)
                        .scaleEffect(x: 1, y: 1.6, anchor: .center)
                }
                .padding(22)
                .background(.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                Spacer()
            }
            .padding(24)
        }
    }
}
