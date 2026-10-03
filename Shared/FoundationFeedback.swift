import Foundation

enum FoundationFeedback {
    static func selectionMessage(
        applicationCount: Int,
        otherCount: Int,
        saved: Bool
    ) -> String {
        guard saved else {
            return "选择未保存；请重试，重启后可能无法保留。"
        }
        guard applicationCount > 0 else {
            if otherCount > 0 {
                return "已保存选择，但本轮仅测试 App；请至少选一个应用，而不只是类别或网站。"
            }
            return "当前没有选中 App。"
        }
        return "已保存 \(applicationCount) 个 App；重启后请核对数量。"
    }

    static func safeErrorCode(_ error: Error) -> String {
        String((error as NSError).code)
    }
}
