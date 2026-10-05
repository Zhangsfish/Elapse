import SwiftUI

/// Generic local drawing only. Fixed sample values are not protected report data.
struct TutorialArtwork: View {
    let scene: TutorialScene
    let frame: TutorialFrame
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            switch scene {
            case .chooseApps: selection
            case .chooseInterval: interval
            case .reminder: reminder
            case .today: today
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 290)
        .background(Color(uiColor: .secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 24))
        .allowsHitTesting(false)
    }

    private var selection: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { row in
                HStack(spacing: 14) {
                    appSymbol(row, selected: row < frame.selectedRows)
                    Text(LocalizedStringKey(appKey(row))).font(.body.weight(.medium))
                    Spacer(minLength: 8)
                    Image(systemName: row < frame.selectedRows ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(row < frame.selectedRows ? Color.accentColor : Color.secondary)
                        .scaleEffect(row < frame.selectedRows ? 1.05 : 1)
                }
                .padding(12)
                .background(Color(uiColor: .tertiarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .trailing) {
                    touch(visible: frame.time > 0.25 && frame.time < 1.65
                          && row == (frame.time < 1 ? 0 : 1))
                        .offset(x: -12, y: 16)
                }
            }
            Label(frame.selectionConfirmed ? "tutorial.demo.selected" : "tutorial.demo.confirm",
                  systemImage: frame.selectionConfirmed ? "checkmark" : "hand.tap")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(frame.selectionConfirmed ? Color.accentColor : Color.secondary)
        }
    }

    private var interval: some View {
        VStack(spacing: 28) {
            Image(systemName: "clock").font(.largeTitle).foregroundStyle(Color.accentColor)
            AnyLayout(dynamicTypeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 10))) {
                ForEach([5, 15, 30], id: \.self) { minutes in
                    Text(duration(minutes))
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 14)
                        .background(minutes == 5 && frame.intervalChosen
                            ? Color.accentColor.opacity(0.16) : Color.secondary.opacity(0.08),
                                    in: RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14).stroke(
                                minutes == 5 && frame.intervalChosen ? Color.accentColor : Color.clear,
                                lineWidth: 2)
                        }
                }
            }
            .overlay(alignment: .leading) {
                touch(visible: frame.time > 0.3 && frame.time < 1.2).offset(x: 24, y: 20)
            }
            Label(frame.monitoringOn ? "home.status.on" : "home.start",
                  systemImage: frame.monitoringOn ? "checkmark.circle.fill" : "play.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(frame.monitoringOn ? Color.primary : Color.white)
                .padding(18).frame(maxWidth: .infinity)
                .background(frame.monitoringOn ? Color.accentColor.opacity(0.14) : Color.accentColor,
                            in: RoundedRectangle(cornerRadius: 18))
                .overlay(alignment: .trailing) {
                    touch(visible: frame.time > 1.35 && frame.time < 2.15).offset(x: -22, y: 20)
                }
        }
    }

    private var reminder: some View {
        VStack(spacing: 24) {
            HStack(spacing: 18) {
                appSymbol(0, selected: true).scaleEffect(frame.time < 1.3 ? 1.15 : 1)
                Image(systemName: "plus").foregroundStyle(.secondary)
                appSymbol(1, selected: true)
                    .scaleEffect(frame.time >= 1.3 && frame.time < 2.3 ? 1.15 : 1)
            }
            Text("tutorial.demo.shared").font(.subheadline).foregroundStyle(.secondary)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.12))
                    Capsule().fill(Color.accentColor)
                        .frame(width: geometry.size.width * CGFloat(frame.sharedUsageProgress))
                }
            }.frame(height: 8)
            VStack(alignment: .leading, spacing: 8) {
                Label("Everwhile", systemImage: "bell.badge").font(.caption.weight(.medium))
                Text("tutorial.demo.fiveMinutes").font(.headline)
                Text("tutorial.demo.pulse").font(.subheadline)
            }
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .tertiarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 20))
            .opacity(frame.bannerOpacity).offset(y: -12 * (1 - frame.bannerOpacity))
        }
    }

    private var today: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("today.title").font(.headline)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .overlay(alignment: .trailing) {
                touch(visible: !frame.reportOpened).offset(y: 20)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("report.total").font(.caption).foregroundStyle(.secondary)
                Text(duration(30)).font(.largeTitle.bold())
            }.opacity(frame.totalOpacity)
            VStack(alignment: .leading, spacing: 8) {
                Text("report.hourly").font(.caption).foregroundStyle(.secondary)
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(Array([12.0, 0, 30, 0, 48, 18].enumerated()), id: \.offset) { item in
                        RoundedRectangle(cornerRadius: 3).fill(Color.accentColor.opacity(0.8))
                            .frame(maxWidth: .infinity).frame(height: CGFloat(item.element))
                    }
                }.frame(height: 52, alignment: .bottom)
            }.opacity(frame.hourlyOpacity)
            VStack(spacing: 10) {
                demoUsageRow(0, minutes: 20)
                demoUsageRow(1, minutes: 10)
            }.opacity(frame.appRowsOpacity)
        }
    }

    private func duration(_ minutes: Int) -> String {
        UsageDurationFormatter.format(Double(minutes * 60),
            language: UsageDurationLanguage.forBundle())
    }

    private func demoUsageRow(_ row: Int, minutes: Int) -> some View {
        AnyLayout(dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))) {
            appSymbol(row, selected: false)
            Text(LocalizedStringKey(appKey(row))).font(.subheadline)
            if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 8) }
            Text(duration(minutes)).font(.subheadline.monospacedDigit())
        }
    }

    private func appKey(_ row: Int) -> String {
        ["tutorial.demo.appA", "tutorial.demo.appB", "tutorial.demo.appC"][row]
    }

    private func appSymbol(_ row: Int, selected: Bool) -> some View {
        Image(systemName: ["square.stack", "bubble.left.and.bubble.right", "headphones"][row])
            .font(.title3).foregroundStyle(selected ? Color.accentColor : Color.primary)
            .frame(width: 44, height: 44)
            .background(Color.accentColor.opacity(selected ? 0.13 : 0.06),
                        in: RoundedRectangle(cornerRadius: 12))
    }

    private func touch(visible: Bool) -> some View {
        Image(systemName: "hand.point.up.left.fill").font(.title2)
            .foregroundStyle(Color(uiColor: .systemBackground))
            .shadow(color: .primary.opacity(0.35), radius: 1)
            .overlay {
                Image(systemName: "hand.point.up.left").font(.title2).foregroundStyle(Color.accentColor)
            }
            .opacity(visible ? 1 : 0)
    }
}
