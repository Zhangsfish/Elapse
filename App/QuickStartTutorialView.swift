import SwiftUI

/// Teaching only: no permission requests, picker, monitor actions or private usage.
struct QuickStartTutorialView: View {
    @Environment(\.dismiss) private var dismiss

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
                Button("tutorial.done") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.regularMaterial)
                    .accessibilityIdentifier("tutorial-done")
            }
            .navigationTitle("tutorial.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("tutorial.skip") { dismiss() }
                        .accessibilityIdentifier("tutorial-skip")
                }
            }
        }
    }
}
