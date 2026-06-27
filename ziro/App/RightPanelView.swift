import SwiftUI
import Combine

struct RightPanelView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ClockWidget(); WeatherWidget(); UpcomingTasksWidget(); HabitProgressWidget()
                CurrentGoalWidget(); ProgressRingWidget(); QuoteWidget()
            }
            .padding(12)
        }
        .background(VisualEffectView().ignoresSafeArea())
    }
}

struct PanelCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                VisualEffectView(material: .popover, blendingMode: .withinWindow)
                    .cornerRadius(10)
            )
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(NSColor.separatorColor).opacity(0.15), lineWidth: 0.5))
    }
}

struct ClockWidget: View {
    @State private var now = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        PanelCard {
            VStack(spacing: 6) {
                Text(now.formatted(date: .omitted, time: .standard))
                    .font(.system(.largeTitle, design: .rounded, weight: .ultraLight))
                    .foregroundColor(.primary)
                    .lineLimit(1).minimumScaleFactor(0.5)
                Text(now.formatted(date: .complete, time: .omitted))
                    .font(.system(.caption2, design: .rounded, weight: .regular))
                    .foregroundColor(.secondary).tracking(0.5)
            }.frame(maxWidth: .infinity)
        }.onReceive(timer) { now = $0 }
    }
}

struct WeatherWidget: View {
    var body: some View {
        PanelCard {
            HStack(spacing: 10) {
                Image(systemName: "sparkle").font(.title2).foregroundColor(.orange.opacity(0.8))
                VStack(alignment: .leading, spacing: 3) {
                    Text("72°").font(.system(.title3, design: .rounded, weight: .semibold))
                    Text("Clear").font(.system(.caption, weight: .regular)).foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
}

struct UpcomingTasksWidget: View {
    var body: some View {
        PanelCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Upcoming").font(.system(.headline, weight: .semibold)).foregroundColor(.primary)
                VStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(i == 0 ? Color.red.opacity(0.7) : (i == 1 ? Color.orange.opacity(0.7) : Color.yellow.opacity(0.7)))
                                .frame(width: 3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sample task \(i + 1)").font(.system(.caption, weight: .regular)).foregroundColor(.primary).lineLimit(1)
                                Text("Today").font(.system(.caption2, weight: .light)).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

struct HabitProgressWidget: View {
    var body: some View {
        PanelCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today's Habits").font(.system(.headline, weight: .semibold)).foregroundColor(.primary)
                HStack(spacing: 14) {
                    ForEach(0..<4) { i in
                        VStack(spacing: 5) {
                            ZStack {
                                Circle().stroke(Color(NSColor.separatorColor).opacity(0.4), lineWidth: 2.5)
                                Circle().trim(from: 0, to: 0.7)
                                    .stroke(Color.green.opacity(0.7), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 30, height: 30)
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundColor(.green.opacity(0.7))
                            }
                            Text("H\(i + 1)").font(.system(.caption2, weight: .light)).foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

struct CurrentGoalWidget: View {
    var body: some View {
        PanelCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Goal").font(.system(.headline, weight: .semibold)).foregroundColor(.primary)
                Text("Complete ziro MVP").font(.system(.callout, weight: .regular)).foregroundColor(.primary).lineLimit(2)
                ProgressView(value: 0.7)
                    .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    .scaleEffect(x: 1, y: 0.6, anchor: .leading)
            }
        }
    }
}

struct ProgressRingWidget: View {
    var body: some View {
        PanelCard {
            VStack(spacing: 10) {
                ZStack {
                    Circle().stroke(Color(NSColor.separatorColor).opacity(0.3), lineWidth: 6)
                    Circle().trim(from: 0, to: 0.65)
                        .stroke(Color.accentColor.opacity(0.7), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("65%").font(.system(.title3, design: .rounded, weight: .semibold))
                        Text("done").font(.system(.caption2, weight: .light)).foregroundColor(.secondary)
                    }
                }.frame(width: 70, height: 70)
                Text("Daily Progress").font(.system(.caption2, weight: .regular)).foregroundColor(.secondary)
            }.frame(maxWidth: .infinity)
        }
    }
}

struct QuoteWidget: View {
    let quotes = [
        "The only way to do great work is to love what you do.",
        "Simplicity is the ultimate sophistication.",
        "Focus on being productive instead of busy.",
        "The secret of getting ahead is getting started.",
    ]
    @State private var currentIndex = 0
    var body: some View {
        PanelCard {
            VStack(spacing: 6) {
                Text("\"\(quotes[currentIndex])\"")
                    .font(.system(.callout, weight: .regular))
                    .foregroundColor(.primary).italic()
                    .multilineTextAlignment(.center).lineLimit(3).minimumScaleFactor(0.8)
                Text("— Daily Wisdom")
                    .font(.system(.caption2, weight: .light)).foregroundColor(.secondary).tracking(0.5)
            }.frame(maxWidth: .infinity)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.8)) { currentIndex = (currentIndex + 1) % quotes.count }
            }
        }
    }
}
