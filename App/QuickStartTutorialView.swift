import SwiftUI

/// Teaching only: no permission requests, picker, monitor actions or private usage.
struct QuickStartTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("home.tagline")
                        .font(.title2.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("tutorial.permission.title")
                            .font(.subheadline.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)
                        Text("tutorial.permission.detail")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    AppSelectionTeachingView()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("tutorial.start.title")
                            .font(.subheadline.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)
                        Text("tutorial.start.detail")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .padding(24)
                .frame(maxWidth: 620, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                // A navigation-bar button caps text growth. Both exits instead
                // live in an unconstrained footer that stacks at accessibility sizes.
                AnyLayout(dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 12))
                    : AnyLayout(HStackLayout(spacing: 12))) {
                    Button("tutorial.skip") { dismiss() }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("tutorial-skip")
                    Button("tutorial.done") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("tutorial-done")
                }
                .font(.body)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.regularMaterial)
            }
            .navigationTitle("tutorial.title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
