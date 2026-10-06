/// Presentation policy only. Does not alter selection, permissions or monitoring.
enum AppSelectionTeaching {
    static func shouldAnimate(reduceMotion: Bool, voiceOver: Bool) -> Bool {
        !reduceMotion && !voiceOver
    }
}
