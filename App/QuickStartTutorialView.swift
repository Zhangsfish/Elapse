import SwiftUI
/// Optional demonstration; no permissions, real selection, monitoring or report actions.
struct QuickStartTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @State private var scene: TutorialScene = .chooseApps

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(LocalizedStringKey(scene.titleKey))
                        .font(.title2.bold()).multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("tutorial-scene-title")
                    GeometryReader { geometry in
                        let scale = min(1, geometry.size.width / 340)
                        TutorialPlayback(scene: scene, animated: AppSelectionTeaching.shouldAnimate(
                            reduceMotion: reduceMotion, voiceOver: voiceOver))
                            .id(scene)
                            .scaleEffect(scale, anchor: .top)
                            .frame(width: geometry.size.width, height: 390 * scale, alignment: .top)
                    }
                        .aspectRatio(340.0 / 390.0, contentMode: .fit)
                        .frame(maxWidth: 340)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(LocalizedStringKey(scene.voiceKey))
                        .accessibilityIdentifier("tutorial-artwork")
                    Text(LocalizedStringKey(scene.detailKey))
                        .font(.subheadline).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        ForEach(TutorialScene.allCases, id: \.rawValue) { item in
                            Capsule()
                                .fill(item == scene ? Color.accentColor : Color.secondary.opacity(0.25))
                                .frame(width: item == scene ? 20 : 6, height: 6)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text("\(scene.rawValue + 1) / \(TutorialScene.allCases.count)"))
                    .accessibilityIdentifier("tutorial-page")
                }
                .padding(24).frame(maxWidth: 500).frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                AnyLayout(dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 10))
                    : AnyLayout(HStackLayout(spacing: 12))) {
                    if scene != .chooseApps {
                        Button("tutorial.previous") { scene = scene.previous }
                            .buttonStyle(.bordered).accessibilityIdentifier("tutorial-previous")
                    }
                    Button(scene == .today ? "tutorial.done" : "tutorial.next") {
                        if scene == .today { dismiss() } else { scene = scene.next }
                    }
                    .buttonStyle(.borderedProminent).accessibilityIdentifier("tutorial-next")
                }
                .font(.body).controlSize(.large)
                .frame(maxWidth: .infinity).padding(16).background(.regularMaterial)
            }
            .navigationTitle("tutorial.title").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("tutorial.skip") { dismiss() }
                        .font(.body)
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityIdentifier("tutorial-skip")
                }
            }
        }
    }
}

/// Lecture Asset's bounded, time-addressable playback pattern; no repeating timers.
private struct TutorialPlayback: View {
    let scene: TutorialScene
    let animated: Bool
    @Environment(\.scenePhase) private var scenePhase
    @State private var start = Date()
    @State private var settled = false

    var body: some View {
        Group {
            if !animated || scenePhase != .active {
                TutorialArtwork(scene: scene, frame: TutorialFrame(time: TutorialFrame.duration))
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 60, paused: settled)) { context in
                    TutorialArtwork(scene: scene, frame: TutorialFrame(time: settled
                        ? TutorialFrame.duration : context.date.timeIntervalSince(start)))
                }
            }
        }
        .task(id: animated) {
            guard animated else { return }
            start = Date()
            settled = false
            do { try await Task.sleep(for: .seconds(TutorialFrame.duration)) }
            catch { return }
            settled = true
        }
    }
}
