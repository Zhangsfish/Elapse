import SwiftUI

/// Read-only, generic illustrations on a 340 × 390 design canvas. All motion is
/// time-addressable; the final frame is also the Reduce Motion/VoiceOver artwork.
/// Sample durations never enter monitoring, App Group or the real Today report.
struct TutorialArtwork: View {
    let scene: TutorialScene
    let frame: TutorialFrame
    private let blue = Color.accentColor

    var body: some View {
        ZStack {
            Ellipse().fill(blue.opacity(0.07)).frame(width: 270, height: 230)
                .blur(radius: 35).position(x: 170, y: 208)
            switch scene {
            case .chooseApps: selection
            case .chooseInterval: interval
            case .reminder: reminder
            case .today: today
            }
        }
        .frame(width: 340, height: 390)
        .allowsHitTesting(false)
    }

    private var selection: some View {
        ZStack {
            ForEach(0..<3) { row in
                let chosen = frame.selection(row)
                let arrive = frame.snap(from: Double(row) * 0.09, to: 0.5 + Double(row) * 0.09)
                HStack(spacing: 16) {
                    appSymbol(row).frame(width: 46, height: 46)
                    drawingText(appKey(row), size: 17, weight: .semibold, alignment: .leading)
                    Spacer(minLength: 0)
                    ZStack {
                        Circle().stroke(blue.opacity(0.25), lineWidth: 1.5)
                        Circle().fill(blue).opacity(chosen)
                        CheckStroke().trim(from: 0, to: chosen)
                            .stroke(.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                            .padding(7)
                    }.frame(width: 28, height: 28)
                }
                .padding(16).frame(width: 288, height: 72)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 21))
                .overlay(RoundedRectangle(cornerRadius: 21).stroke(blue.opacity(0.35 * chosen), lineWidth: 1.5))
                .shadow(color: blue.opacity(0.06 + chosen * 0.04), radius: 12, y: 6)
                .scaleEffect(1 + 0.025 * chosen)
                .position(x: 170 + 18 * (1 - arrive), y: 92 + CGFloat(row) * 84)
                .opacity(frame.progress(from: Double(row) * 0.09, to: 0.35 + Double(row) * 0.09))
            }
            ZStack {
                drawingText("tutorial.demo.confirm", size: 15, weight: .semibold)
                    .opacity(1 - frame.selectionConfirmation)
                drawingText("tutorial.demo.selected", size: 15, weight: .semibold, color: blue)
                    .opacity(frame.selectionConfirmation)
            }.frame(width: 240, height: 34).position(x: 170, y: 335)
            touch(opacity: frame.selectionHandOpacity)
                .position(x: 289, y: frame.selectionHandY)
        }
    }

    private var interval: some View {
        ZStack {
            Circle().stroke(blue.opacity(0.13), lineWidth: 1.5).frame(width: 104, height: 104)
                .position(x: 170, y: 99)
            Circle().trim(from: 0, to: frame.intervalSelection * 0.72)
                .stroke(blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 104, height: 104).rotationEffect(.degrees(-90)).position(x: 170, y: 99)
            Image(systemName: "clock").font(.system(size: 38, weight: .light))
                .foregroundStyle(blue).rotationEffect(.degrees(-8 * (1 - frame.intervalSelection)))
                .position(x: 170, y: 99)
            ForEach(Array([5, 15, 30].enumerated()), id: \.offset) { item in
                let chosen = item.offset == 0 ? frame.intervalSelection : 0
                drawingValue(duration(item.element), size: 18, weight: .semibold)
                    .frame(width: 86, height: 62)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 19))
                    .overlay(RoundedRectangle(cornerRadius: 19).fill(blue.opacity(chosen * 0.12)))
                    .overlay(RoundedRectangle(cornerRadius: 19).stroke(blue.opacity(chosen), lineWidth: 2))
                    .shadow(color: blue.opacity(chosen * 0.12), radius: 12, y: 5)
                    .scaleEffect(1 - 0.07 * (item.offset == 0 ? frame.intervalPress : 0))
                    .offset(y: -3 * chosen)
                    .position(x: 72 + CGFloat(item.offset) * 98, y: 200)
            }
            ZStack {
                Capsule().fill(blue).opacity(1 - frame.monitoringProgress)
                Capsule().fill(blue.opacity(0.12)).opacity(frame.monitoringProgress)
                HStack(spacing: 9) {
                    Image(systemName: "play.fill").font(.system(size: 13))
                    drawingText("home.start", size: 16, weight: .semibold, color: .white)
                }.padding(.horizontal, 25).foregroundStyle(.white)
                    .opacity(1 - frame.monitoringProgress).scaleEffect(1 - 0.12 * frame.monitoringProgress)
                HStack(spacing: 9) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(blue)
                    drawingText("home.status.on", size: 16, weight: .semibold, color: blue)
                }.padding(.horizontal, 25).opacity(frame.monitoringProgress)
                    .scaleEffect(0.85 + 0.15 * frame.snap(from: 1.65, to: 2.5))
            }.frame(width: 284 - 18 * frame.monitoringProgress, height: 60)
                .scaleEffect(1 - 0.04 * frame.startPress)
                .position(x: 170, y: 289)
            touch(opacity: frame.intervalHandOpacity)
                .position(x: 83 + 160 * frame.progress(from: 0.95, to: 1.35), y: frame.intervalHandY)
        }
    }

    private var reminder: some View {
        ZStack {
            ForEach(0..<2) { row in
                let pulse = frame.progress(from: 0.3 + Double(row) * 0.85, to: 0.65 + Double(row) * 0.85)
                    * (1 - frame.progress(from: 1 + Double(row) * 0.85, to: 1.3 + Double(row) * 0.85))
                appSymbol(row).frame(width: 60, height: 60).scaleEffect(1 + 0.1 * pulse)
                    .position(x: row == 0 ? 115 : 225, y: 91)
            }
            Image(systemName: "plus").font(.system(size: 15, weight: .medium))
                .foregroundStyle(blue.opacity(0.6)).position(x: 170, y: 91)
            drawingText("tutorial.demo.shared", size: 14, color: .secondary)
                .frame(width: 260, height: 28).position(x: 170, y: 148)
            Capsule().fill(blue.opacity(0.12)).frame(width: 250, height: 7).position(x: 170, y: 180)
            Capsule().fill(blue).frame(width: 250 * frame.sharedUsageProgress, height: 7)
                .position(x: 45 + 125 * frame.sharedUsageProgress, y: 180)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 25).fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: blue.opacity(0.13), radius: 20, y: 10)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell").font(.system(size: 12)).foregroundStyle(blue)
                        drawingValue("Everwhile", size: 12, weight: .medium, alignment: .leading)
                    }.frame(height: 16)
                    drawingText("tutorial.demo.fiveMinutes", size: 21, weight: .semibold, alignment: .leading)
                        .frame(height: 25)
                    drawingText("tutorial.demo.pulse", size: 14, color: .secondary, alignment: .leading)
                        .frame(height: 44)
                }.padding(21)
            }.frame(width: 292, height: 145)
                .scaleEffect(0.95 + 0.05 * frame.bannerPosition)
                .position(x: 170, y: 290 - 78 * (1 - frame.bannerPosition))
                .opacity(frame.bannerOpacity)
        }
    }

    private var today: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: blue.opacity(0.09), radius: 18, y: 9)
                .frame(width: 300, height: 350).position(x: 170, y: 198)
            drawingText("today.title", size: 14, weight: .semibold, alignment: .leading)
                .frame(width: 250, height: 22).position(x: 170, y: 58)
            VStack(alignment: .leading, spacing: 6) {
                drawingText("report.total", size: 11, color: .secondary, alignment: .leading).frame(height: 16)
                drawingValue(duration(30), size: 32, weight: .bold, alignment: .leading).frame(height: 38)
            }.frame(width: 250).position(x: 170, y: 112)
                .offset(y: 8 * (1 - frame.totalOpacity)).opacity(frame.totalOpacity)
            drawingText("report.hourly", size: 11, color: .secondary, alignment: .leading)
                .frame(width: 250, height: 18).position(x: 170, y: 169)
            Canvas { context, _ in
                var baseline = Path()
                baseline.move(to: CGPoint(x: 0, y: 75))
                baseline.addLine(to: CGPoint(x: 250, y: 75))
                context.stroke(baseline, with: .color(blue.opacity(0.15)), lineWidth: 1)
                // Fixed illustrative hourly shape, never real sessions or protected usage.
                for (index, height) in [24.0, 10, 39, 0, 62, 28, 48, 16].enumerated() {
                    let grown = height * frame.barGrowth(index)
                    let rect = CGRect(x: Double(index) * 32, y: 75 - grown, width: 17, height: grown)
                    context.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(blue.opacity(0.8)))
                }
            }.frame(width: 250, height: 76).position(x: 170, y: 221)
            ForEach(0..<2) { row in
                let appear = frame.rowAppearance(row)
                HStack(spacing: 12) {
                    appSymbol(row).frame(width: 33, height: 33)
                    drawingText(appKey(row), size: 14, weight: .medium, alignment: .leading)
                    drawingValue(duration(row == 0 ? 20 : 10), size: 14, weight: .semibold, alignment: .trailing)
                        .frame(width: 60)
                }.frame(width: 250, height: 38)
                    .position(x: 170 + 14 * (1 - appear), y: 299 + CGFloat(row) * 47)
                    .opacity(appear)
            }
        }.opacity(frame.reportProgress).scaleEffect(0.94 + 0.06 * frame.reportProgress)
    }

    private func appSymbol(_ row: Int) -> some View {
        GeometryReader { geometry in
            let side = geometry.size.width
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.27).fill(blue.opacity(0.11))
                Image(systemName: ["square.stack", "bubble.left.and.bubble.right", "headphones"][row])
                    .font(.system(size: side * 0.43, weight: .medium)).foregroundStyle(blue)
            }
        }
    }

    private func touch(opacity: Double) -> some View {
        Image(systemName: "hand.point.up.left.fill").font(.system(size: 31))
            .foregroundStyle(Color(uiColor: .systemBackground))
            .overlay(Image(systemName: "hand.point.up.left").font(.system(size: 31)).foregroundStyle(blue))
            .shadow(color: blue.opacity(0.2), radius: 5, y: 4).opacity(opacity)
    }

    private func appKey(_ row: Int) -> String {
        ["tutorial.demo.appA", "tutorial.demo.appB", "tutorial.demo.appC"][row]
    }
    private func duration(_ minutes: Int) -> String {
        UsageDurationFormatter.format(Double(minutes * 60), language: UsageDurationLanguage.forBundle())
    }
    private func drawingText(_ key: String, size: CGFloat, weight: Font.Weight = .regular,
                             color: Color = .primary, alignment: Alignment = .center) -> some View {
        drawingValue(NSLocalizedString(key, comment: "Tutorial illustration"), size: size,
                     weight: weight, color: color, alignment: alignment)
    }
    /// Graphics labels are not controls. The parent has a localized VoiceOver
    /// summary; title, caption, Skip and navigation remain real Dynamic Type text.
    private func drawingValue(_ value: String, size: CGFloat, weight: Font.Weight = .regular,
                              color: Color = .primary, alignment: Alignment = .center) -> some View {
        Canvas { context, bounds in
            let text = Text(value).font(.system(size: size, weight: weight)).foregroundColor(color)
            let resolved = context.resolve(text)
            let natural = resolved.measure(in: CGSize(width: .infinity, height: .infinity))
            if natural.width > bounds.width {
                context.draw(resolved, in: CGRect(origin: .zero, size: bounds))
            } else {
                let x = alignment == .leading ? 0 : (alignment == .trailing ? bounds.width : bounds.width / 2)
                let anchor: UnitPoint = alignment == .leading ? .leading : (alignment == .trailing ? .trailing : .center)
                context.draw(resolved, at: CGPoint(x: x, y: bounds.height / 2), anchor: anchor)
            }
        }
    }
}

private struct CheckStroke: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.37, y: rect.height * 0.88))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.1))
        return path
    }
}
