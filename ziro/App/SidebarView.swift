import SwiftUI

struct SidebarView: View {
    @Binding var selectedItem: SidebarItem; @Binding var width: CGFloat
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Image(systemName: "square.fill.on.circle.fill")
                    .font(.system(size: 28, weight: .ultraLight))
                    .foregroundColor(.primary)
                Text("ziro")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .tracking(4)
                    .foregroundColor(.primary)
            }
            .padding(.top, 24)
            .padding(.bottom, 28)

            VStack(spacing: 1) {
                ForEach(SidebarItem.allCases, id: \.self) { item in
                    SidebarButton(item: item, isSelected: selectedItem == item, action: { selectedItem = item })
                }
            }

            Spacer()

            VStack(spacing: 8) {
                Rectangle().fill(Color(NSColor.separatorColor).opacity(0.3)).frame(height: 1)
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill").font(.system(size: 9)).foregroundColor(.pink.opacity(0.6))
                    Text("crafted").font(.system(size: 10, weight: .light)).foregroundColor(.secondary).tracking(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 10)
        .background(VisualEffectView().ignoresSafeArea())
    }
}

struct SidebarButton: View {
    let item: SidebarItem; let isSelected: Bool; let action: () -> Void
    @State private var isHovered = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 13, weight: .regular))
                    .frame(width: 18)
                Text(item.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .medium : .regular))
                    .tracking(0.3)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor.opacity(0.12))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.accentColor.opacity(0.25), lineWidth: 0.5))
                    }
                }
            )
            .foregroundColor(isSelected ? .accentColor : (isHovered ? .primary : .secondary.opacity(0.8)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) { isHovered = hovering }
        }
    }
}
