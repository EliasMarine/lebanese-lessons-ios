import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 80
    var lineWidth: CGFloat = 8
    var tint: Color = Theme.brand

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 24) {
        ProgressRing(progress: 0.75, tint: Theme.vividGreen)
        ProgressRing(progress: 0.4, size: 60, lineWidth: 6, tint: Theme.brand)
        ProgressRing(progress: 1.0, size: 100, lineWidth: 10, tint: Theme.brightPurple)
    }
    .padding()
}
