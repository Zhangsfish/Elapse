import SwiftUI
import UIKit

/// Local product help only; no monitoring, report-data or account access.
struct AboutSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var tutorialPresented = false
    @State private var emailCopied = false

    private let email = "zhangs.taq@gmail.com"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // A height-adaptive header avoids the native toolbar's text-size
                // cap, as in the accepted tutorial. Form rows remain native.
                AnyLayout(dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                    : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))) {
                    Text("about.title").font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                    if !dynamicTypeSize.isAccessibilitySize { Spacer() }
                    Button("about.done") { dismiss() }
                        .font(.body)
                        .fixedSize(horizontal: true, vertical: true)
                        .accessibilityIdentifier("about-close")
                }
                // Spacer inside an erased layout must not consume vertical
                // space reserved for the Form. Keep this header intrinsic.
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Form {
                    Section("about.usageTitle") {
                        Button("tutorial.replay", systemImage: "play.circle") { tutorialPresented = true }
                            .accessibilityIdentifier("about-tutorial-replay")
                        Label("about.setup", systemImage: "slider.horizontal.3")
                        Label("about.today", systemImage: "chart.bar.xaxis")
                    }
                    Section("about.contactTitle") {
                        Button {
                            if let url = URL(string: "mailto:\(email)") { openURL(url) }
                        } label: {
                            Label { Text(verbatim: email) } icon: { Image(systemName: "envelope") }
                        }
                        .accessibilityIdentifier("about-email")
                        Button(emailCopied ? "about.emailCopied" : "about.copyEmail",
                               systemImage: emailCopied ? "checkmark" : "doc.on.doc") {
                            UIPasteboard.general.string = email
                            emailCopied = true
                        }
                        .accessibilityIdentifier("about-copy-email")
                        Button {
                            if let url = URL(string: "https://zhang-shuo-portfolio.vercel.app/") { openURL(url) }
                        } label: {
                            Label("about.homepage", systemImage: "arrow.up.right.square")
                        }
                        .accessibilityIdentifier("about-homepage")
                    }
                    Section("about.privacyTitle") {
                        Text("about.privacySimple")
                        Text("about.privacyLocal")
                    }
                    Section("about.versionTitle") {
                        Text(verbatim: version)
                            .accessibilityIdentifier("about-version")
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $tutorialPresented) {
            QuickStartTutorialView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .task(id: emailCopied) {
            guard emailCopied else { return }
            do {
                try await Task.sleep(for: .seconds(2))
                emailCopied = false
            } catch { /* Dismissal cancels the short confirmation. */ }
        }
    }

    private var version: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
