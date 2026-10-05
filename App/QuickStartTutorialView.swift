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
                    TutorialPlayback(scene: scene, animated: AppSelectionTeaching.shouldAnimate(
                        reduceMotion: reduceMotion, voiceOver: voiceOver))
                        .id(scene)
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
                        Text("\(scene.rawValue + 1) / \(TutorialScene.allCases.count)").font(.caption)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("tutorial-page")
                    Text("tutorial.demo").font(.caption).foregroundStyle(.secondary)
                }
                .padding(24).frame(maxWidth: 500).frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                AnyLayout(dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 10))
                    : AnyLayout(HStackLayout(spacing: 12))) {
                    Button("tutorial.skip") { dismiss() }
                        .buttonStyle(.bordered).accessibilityIdentifier("tutorial-skip")
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
                TimelineView(.animation(minimumInterval: 1.0 / 30, paused: settled)) { context in
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
