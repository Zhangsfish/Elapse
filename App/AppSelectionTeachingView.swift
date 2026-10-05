import SwiftUI

/// Generic illustration, not a replacement picker or a display of private tokens.
struct AppSelectionTeachingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @State private var selectedRows = 0

    private var animate: Bool {
        AppSelectionTeaching.shouldAnimate(reduceMotion: reduceMotion, voiceOver: voiceOver)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("selectionGuide.title")
                .font(.subheadline.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 8) {
                ForEach(0..<3) { row in
                    HStack(spacing: 10) {
                        Image(systemName: "app.dashed")
                        Text("selectionGuide.exampleApp")
                        Spacer(minLength: 8)
                        Image(systemName: row < (animate ? selectedRows : 2) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(row < (animate ? selectedRows : 2) ? Color.accentColor : Color.secondary)
                    }
                }
                Label("selectionGuide.confirm", systemImage: "checkmark")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption)
            .padding(12)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
            Text("selectionGuide.detail")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("selection-guide-instruction")
        }
        .task(id: animate) {
            guard animate else { selectedRows = 2; return }
            selectedRows = 0
            for count in 1...2 {
                do { try await Task.sleep(for: .milliseconds(600)) } catch { return }
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.2)) { selectedRows = count }
            }
        }
    }
}
