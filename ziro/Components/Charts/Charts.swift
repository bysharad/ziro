import SwiftUI

struct CircularProgressView: View {
    let progress: Double; let lineWidth: CGFloat; let gradientColors: [Color]
    @State private var animatedProgress: Double = 0
    var body: some View {
        ZStack {
            Circle().stroke(Color(NSColor.separatorColor).opacity(0.3), lineWidth: lineWidth)
            Circle().trim(from: 0, to: animatedProgress).stroke(AngularGradient(colors: gradientColors, center: .center), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)).rotationEffect(.degrees(-90)).animation(.easeOut(duration: 0.8), value: animatedProgress)
        }.onAppear { animatedProgress = progress }
    }
}

struct LinearProgressBarView: View {
    let progress: Double; let height: CGFloat; let color: Color
    @State private var animatedProgress: Double = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2).fill(Color(NSColor.separatorColor).opacity(0.2)).frame(height: height)
                RoundedRectangle(cornerRadius: height / 2).fill(LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .leading, endPoint: .trailing)).frame(width: geometry.size.width * animatedProgress, height: height).animation(.easeOut(duration: 0.6), value: animatedProgress)
            }
        }.onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { animatedProgress = progress } }
    }
}

struct DonutChartView: View {
    let data: [DonutSegment]; let innerRadius: CGFloat; let outerRadius: CGFloat
    @State private var animatedSegments: [Double] = []
    var body: some View {
        ZStack { ForEach(Array(data.enumerated()), id: \.offset) { index, segment in DonutSegmentView(startAngle: startAngle(for: index), endAngle: endAngle(for: index), color: segment.color, innerRadius: innerRadius, outerRadius: outerRadius, animatedValue: animatedSegments[safe: index] ?? 0) } }
            .onAppear {
                let total = data.map(\.value).reduce(0, +)
                animatedSegments = data.reduce(into: []) { arr, seg in arr.append((arr.last ?? 0) + seg.value) }.map { $0 / total }
            }
    }
    private func startAngle(for index: Int) -> Angle { let total = data.map(\.value).reduce(0, +); var c: Double = 0; for i in 0..<index { c += data[i].value }; return Angle(degrees: c / total * 360 - 90) }
    private func endAngle(for index: Int) -> Angle { let total = data.map(\.value).reduce(0, +); var c: Double = 0; for i in 0...index { c += data[i].value }; return Angle(degrees: c / total * 360 - 90) }
}

struct DonutSegmentView: View {
    let startAngle: Angle; let endAngle: Angle; let color: Color; let innerRadius: CGFloat; let outerRadius: CGFloat; let animatedValue: Double
    var body: some View {
        let spanDegrees = (endAngle.degrees - startAngle.degrees) * animatedValue
        let midAngleDegrees = startAngle.degrees + spanDegrees
        return Path { path in
            let center = CGPoint.zero
            path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: Angle(degrees: midAngleDegrees), clockwise: false)
            path.addArc(center: center, radius: innerRadius, startAngle: Angle(degrees: midAngleDegrees), endAngle: startAngle, clockwise: true)
        }.fill(color).rotationEffect(.degrees(90))
    }
}

struct DonutSegment: Identifiable { let id = UUID(); let label: String; let value: Double; let color: Color }

struct SparklineView: View {
    let data: [Double]; let lineColor: Color; @State private var animatedData: [Double] = []
    var body: some View {
        GeometryReader { geometry in
            guard !data.isEmpty else { return AnyView(EmptyView()) }
            let maxValue = data.max() ?? 1; let minValue = data.min() ?? 0; let range = maxValue - minValue > 0 ? maxValue - minValue : 1; let stepX = geometry.size.width / CGFloat(data.count - 1)
            return AnyView(Path { path in
                guard !animatedData.isEmpty else { return }
                for (index, value) in animatedData.enumerated() {
                    let x = CGFloat(index) * stepX; let y = geometry.size.height - CGFloat((value - minValue) / range) * geometry.size.height
                    if index == 0 { path.move(to: CGPoint(x: x, y: y)) } else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }.stroke(lineColor, lineWidth: 1.5))
        }.onAppear {
            animatedData = []; var ci = 0
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if ci < data.count { animatedData.append(data[ci]); ci += 1 } else { timer.invalidate() }
            }
        }
    }
}

extension Array { subscript(safe index: Int) -> Element? { indices ~= index ? self[index] : nil } }
