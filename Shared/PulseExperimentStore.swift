import Foundation
import Darwin

enum PulseExperimentStoreError: Error {
    case groupUnavailable
    case lockUnavailable
}

/// A small app-group JSON file, serialized with a cross-process file lock.
/// Reads fail closed if the file is corrupt; an extension never guesses that
/// an unreadable current experiment is safe to notify.
final class PulseExperimentStore {
    static let groupID = "group.com.zhangsfish.elapse"

    private let fileManager = FileManager.default
    private let stateURL: URL
    private let lockURL: URL

    static func live() throws -> PulseExperimentStore {
        guard let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        ) else {
            throw PulseExperimentStoreError.groupUnavailable
        }
        return try PulseExperimentStore(directory: container.appendingPathComponent("PulseDiagnostics", isDirectory: true))
    }

    init(directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        stateURL = directory.appendingPathComponent("experiment.json")
        lockURL = directory.appendingPathComponent("experiment.lock")
    }

    func read() throws -> PulseExperimentSnapshot {
        try withLock { try loadUnlocked() }
    }

    @discardableResult
    func update<T>(_ change: (inout PulseExperimentSnapshot) -> T) throws -> T {
        try withLock {
            var snapshot = try loadUnlocked()
            let result = change(&snapshot)
            let bytes = try JSONEncoder().encode(snapshot)
            try bytes.write(to: stateURL, options: .atomic)
            #if os(iOS)
            try fileManager.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: stateURL.path
            )
            #endif
            return result
        }
    }

    private func loadUnlocked() throws -> PulseExperimentSnapshot {
        guard fileManager.fileExists(atPath: stateURL.path) else {
            return PulseExperimentSnapshot()
        }
        return try JSONDecoder().decode(PulseExperimentSnapshot.self, from: Data(contentsOf: stateURL))
    }

    private func withLock<T>(_ body: () throws -> T) throws -> T {
        let descriptor = open(lockURL.path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor >= 0 else { throw PulseExperimentStoreError.lockUnavailable }
        defer { close(descriptor) }
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: lockURL.path
        )
        #endif
        guard flock(descriptor, LOCK_EX) == 0 else {
            throw PulseExperimentStoreError.lockUnavailable
        }
        defer { flock(descriptor, LOCK_UN) }
        return try body()
    }
}
