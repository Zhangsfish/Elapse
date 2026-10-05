/// Presentation policy only. Does not alter selection, permissions or monitoring.
enum AppSelectionTeaching {
    static func showInline(authorized: Bool, selectedAppCount: Int, canChangeSelection: Bool) -> Bool {
        authorized && selectedAppCount == 0 && canChangeSelection
    }

    static func shouldAnimate(reduceMotion: Bool, voiceOver: Bool) -> Bool {
        !reduceMotion && !voiceOver
    }
}
