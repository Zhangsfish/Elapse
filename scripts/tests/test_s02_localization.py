import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
KEY_PATTERN = re.compile(r'^"([^"]+)"\s*=\s*"((?:[^"\\]|\\.)*)";\s*$', re.MULTILINE)
REFERENCE_PATTERN = re.compile(r'"((?:home|about|diagnostics|today|report|selectionGuide|tutorial|pulse)\.[A-Za-z0-9.]+)"')


def release_content_view():
    source = (ROOT / "App/ContentView.swift").read_text(encoding="utf-8")
    # These narrow DEBUG blocks have no nested directives. Native Release UI
    # tests additionally verify the actual compiler's result, not only text.
    return re.sub(r'(?ms)^\s*#if DEBUG\n.*?^\s*#endif\n', '', source)


class S02LocalizationTests(unittest.TestCase):
    def test_languages_have_matching_unique_keys_and_all_ui_references(self):
        languages = {}
        for language in ("en", "zh-Hans"):
            source = (ROOT / "Localization" / f"{language}.lproj" / "Localizable.strings").read_text(
                encoding="utf-8"
            )
            pairs = KEY_PATTERN.findall(source)
            self.assertEqual(len(pairs), len(set(key for key, _ in pairs)))
            languages[language] = {key for key, _ in pairs}
        self.assertEqual(languages["en"], languages["zh-Hans"])
        for file in (ROOT / "App" / "ContentView.swift", ROOT / "App" / "AboutSupportView.swift",
                     ROOT / "App" / "QuickStartTutorialView.swift",
                     ROOT / "App" / "TutorialArtwork.swift", ROOT / "Shared" / "TutorialStoryboard.swift",
                     ROOT / "ReportExtension" / "ElapseReportExtension.swift", ROOT / "Shared" / "PulsePlan.swift"):
            references = set(REFERENCE_PATTERN.findall(file.read_text(encoding="utf-8")))
            self.assertFalse(references - languages["en"], f"Missing localizations in {file}")

    def test_release_has_only_public_menu_and_no_diagnostics_path(self):
        release = release_content_view()
        for forbidden in ("DiagnosticsView", "diagnosticsPresented", '"home.diagnostics"',
                          '"diagnostics.', "developer-diagnostics", "diagnosticSummary",
                          "sendOrdinaryTestNotification", "UIPasteboard"):
            self.assertNotIn(forbidden, release)
        menu = release.split("Menu {", 1)[1].split("} label:", 1)[0]
        self.assertEqual(menu.count("Button("), 2)
        self.assertIn('Button("tutorial.replay"', menu)
        self.assertIn('Button("about.title"', menu)
        self.assertIn('.sheet(isPresented: $aboutPresented) { AboutSupportView() }', release)

    def test_about_support_links_version_and_local_only_surface(self):
        about = (ROOT / "App/AboutSupportView.swift").read_text(encoding="utf-8")
        self.assertIn('private let email = "zhangs.taq@gmail.com"', about)
        self.assertIn('URL(string: "mailto:\\(email)")', about)
        self.assertIn('URL(string: "https://zhang-shuo-portfolio.vercel.app/")', about)
        self.assertEqual(about.count("openURL(url)"), 2)
        self.assertIn("UIPasteboard.general.string = email", about)
        self.assertIn("Bundle.main.infoDictionary", about)
        for key in ("CFBundleShortVersionString", "CFBundleVersion"):
            self.assertIn(f'info?["{key}"] as? String', about)
        self.assertIn('return "\\(version) (\\(build))"', about)
        self.assertNotIn("0.1.0", about)
        self.assertIn('Section("about.versionTitle")', about)
        self.assertGreaterEqual(about.count('.fixedSize(horizontal: false, vertical: true)'), 2,
                                'Title and header must keep their intrinsic height above the Form')
        self.assertIn('.toolbar(.hidden, for: .navigationBar)', about)
        self.assertIn('.labelStyle(SupportRowLabelStyle())', about)
        row_style = about.split('private struct SupportRowLabelStyle', 1)[1]
        self.assertIn('configuration.title\n                .fixedSize(horizontal: false, vertical: true)', row_style)
        self.assertIn('.accessibilityHidden(true)', row_style)
        privacy = about.split('Section("about.privacyTitle")', 1)[1].split(
            'Section("about.versionTitle")', 1)[0]
        self.assertEqual(privacy.count('Text("about.privacy'), 2)
        for forbidden in ("ElapseModel", "PulseExperimentStore", "UserDefaults", "URLSession",
                          "DeviceActivity", "FamilyControls", "diagnosticSummary"):
            self.assertNotIn(forbidden, about)

    def test_support_ui_audits_report_elements_without_suppression(self):
        ui_tests = (ROOT / "UITests/S02PolishUITests.swift").read_text(encoding="utf-8")
        audit = ui_tests.split("private func auditSupport", 1)[1]
        self.assertIn("[.dynamicType, .textClipped]", audit)
        self.assertIn("issue.element?.debugDescription", audit)
        self.assertIn("return false", audit)
        self.assertNotIn("return true", audit)
        smoke = (ROOT / "scripts/s02_ui_smoke.sh").read_text(encoding="utf-8")
        self.assertEqual(smoke.count("|| ui_status=1"), 2)
        self.assertIn('exit "$ui_status"', smoke)

    def test_public_copy_has_no_testing_seams_and_bilingual_support_is_exact(self):
        public_views = release_content_view() + (ROOT / "App/AboutSupportView.swift").read_text(encoding="utf-8")
        public_keys = set(REFERENCE_PATTERN.findall(public_views))
        expected = {
            "en": ("About & Support", "Choose apps · Set interval · Start",
                   "Today shows total · by hour · by app", "No account, no ads, no analytics.",
                   "Screen Time data stays on this iPhone and is not uploaded by Everwhile."),
            "zh-Hans": ("关于与支持", "选择 App · 设置间隔 · 开始",
                        "Today 显示总量 · 每小时 · 各 App", "无账号、无广告、无分析。",
                        "屏幕使用时间数据留在这台 iPhone 上，Everwhile 不会上传。"),
        }
        for language, values in expected.items():
            strings = dict(KEY_PATTERN.findall((ROOT / "Localization" / f"{language}.lproj" /
                                                "Localizable.strings").read_text(encoding="utf-8")))
            self.assertEqual(tuple(strings[key] for key in ("about.title", "about.setup", "about.today",
                                                           "about.privacySimple", "about.privacyLocal")), values)
            for key in public_keys:
                self.assertNotRegex(strings[key], r'(?i)\b(test|diagnostics?|uuid|configuration|events?|generation|callbacks?|recoveries|recovery|development)\b|高级诊断|回调|代数|配置 ID|事件数|S0[0123]')

    def test_tutorial_is_teaching_only_and_keeps_sample_data_local(self):
        artwork = (ROOT / "App" / "TutorialArtwork.swift").read_text(encoding="utf-8")
        view = (ROOT / "App" / "QuickStartTutorialView.swift").read_text(encoding="utf-8")
        for forbidden in ("import DeviceActivity", "import FamilyControls", "import UserNotifications",
                          "PulseExperimentStore", "startMonitoring(", "UNNotificationRequest(",
                          "UserDefaults", "ApplicationToken", "DeviceActivityReport("):
            self.assertNotIn(forbidden, artwork + view)
        self.assertIn(".allowsHitTesting(false)", artwork)
        self.assertNotIn('Text("tutorial.demo")', view)
        self.assertIn("minimumInterval: 1.0 / 60", view)
        self.assertIn("paused: settled", view)
        self.assertIn("scenePhase != .active", view)

    def test_no_dead_localizations_or_teaching_view(self):
        self.assertFalse((ROOT / "App" / "AppSelectionTeachingView.swift").exists())
        sources = "\n".join(file.read_text(encoding="utf-8")
                            for folder in ("App", "Shared", "MonitorExtension", "ReportExtension")
                            for file in (ROOT / folder).glob("*.swift"))
        references = set(REFERENCE_PATTERN.findall(sources))
        keys = set(dict(KEY_PATTERN.findall(
            (ROOT / "Localization/en.lproj/Localizable.strings").read_text(encoding="utf-8"))))
        self.assertFalse(keys - references, f"Unused keys: {sorted(keys - references)}")
        self.assertFalse(references - keys, f"Missing keys: {sorted(references - keys)}")
        for prefix in ("selectionGuide.", "tutorial.permission.", "tutorial.start."):
            self.assertFalse(any(key.startswith(prefix) for key in keys))

    def test_interval_teaching_previews_setting_not_elapsed_time(self):
        artwork = (ROOT / "App" / "TutorialArtwork.swift").read_text(encoding="utf-8")
        interval = artwork.split("private var interval: some View {", 1)[1].split(
            "private var reminder: some View {", 1)[0]
        self.assertIn('Image(systemName: "clock")', interval)
        self.assertIn('drawingValue(duration(5), size: 36', interval)
        self.assertIn('.opacity(frame.intervalSelection)', interval)
        for elapsed_visual in ('Circle()', '.trim(', '.rotationEffect(', 'sharedUsageProgress'):
            self.assertNotIn(elapsed_visual, interval)
        self.assertIn('frame.intervalPress', interval)
        self.assertIn('frame.startPress', interval)
        self.assertIn('frame.monitoringProgress', interval)

    def test_notification_templates_and_monitor_resources(self):
        for language in ("en", "zh-Hans"):
            pairs = dict(KEY_PATTERN.findall(
                (ROOT / "Localization" / f"{language}.lproj" / "Localizable.strings").read_text(encoding="utf-8")
            ))
            self.assertEqual(pairs["pulse.title"].count("%ld"), 1)
            self.assertEqual(pairs["pulse.body"].count("%ld"), 1)
        project = (ROOT / "project.yml").read_text(encoding="utf-8")
        monitor = project.split("  ElapseMonitor:\n", 1)[1].split("  ElapseReport:\n", 1)[0]
        self.assertIn("- path: Localization", monitor)
        self.assertIn("CFBundleDevelopmentRegion: en", monitor)


if __name__ == "__main__":
    unittest.main()
