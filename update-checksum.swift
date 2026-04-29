#!/usr/bin/env swift

import Foundation
import CryptoKit

// MARK: - Errors

enum UpdateChecksumError: Error, LocalizedError {
    case binaryUrlNotFound
    case checksumNotFound
    case invalidUrl(String)
    case downloadFailed(URL, statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .binaryUrlNotFound:
            return #"Could not find `let binaryUrl = "..."` in Package.swift"#
        case .checksumNotFound:
            return #"Could not find `let checksum = "..."` in Package.swift"#
        case .invalidUrl(let value):
            return "Invalid URL: \(value)"
        case .downloadFailed(let url, let statusCode):
            return "Download failed for \(url.absoluteString) — HTTP \(statusCode)"
        }
    }
}

// MARK: - Package Manifest

struct PackageManifest {
    static let binaryUrlPattern = #"let binaryUrl = "([^"]+)""#
    static let checksumPattern = #"let checksum = "([^"]+)""#

    let fileURL: URL

    func binaryUrl() throws -> URL {
        print("\(Self.self).\(#function)")
        let raw = try firstCapture(matching: Self.binaryUrlPattern,
                                   onMissing: UpdateChecksumError.binaryUrlNotFound)
        guard let url = URL(string: raw) else {
            throw UpdateChecksumError.invalidUrl(raw)
        }
        print("\(Self.self).\(#function) — \(url.absoluteString)")
        return url
    }

    func updateChecksum(to newChecksum: String) throws {
        print("\(Self.self).\(#function) — \(newChecksum)")
        var text = try String(contentsOf: fileURL, encoding: .utf8)
        let regex = try NSRegularExpression(pattern: Self.checksumPattern)
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: nsRange),
              let captureRange = Range(match.range(at: 1), in: text) else {
            throw UpdateChecksumError.checksumNotFound
        }
        text.replaceSubrange(captureRange, with: newChecksum)
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
        print("\(Self.self).\(#function) — wrote \(fileURL.path)")
    }

    func firstCapture(matching pattern: String,
                              onMissing missingError: UpdateChecksumError) throws -> String {
        let text = try String(contentsOf: fileURL, encoding: .utf8)
        let regex = try NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: nsRange),
              let captureRange = Range(match.range(at: 1), in: text) else {
            throw missingError
        }
        return String(text[captureRange])
    }
}

// MARK: - Downloader

struct ArtifactDownloader {
    func download(from url: URL) async throws -> URL {
        print("\(Self.self).\(#function) — \(url.absoluteString)")
        let (tempFile, response) = try await URLSession.shared.download(from: url)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw UpdateChecksumError.downloadFailed(url, statusCode: http.statusCode)
        }
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.removeItem(at: destination)
        try FileManager.default.moveItem(at: tempFile, to: destination)
        print("\(Self.self).\(#function) — saved to \(destination.path)")
        return destination
    }
}

// MARK: - Checksum

enum SwiftPackageChecksum {
    /// Mirrors `swift package compute-checksum`: SHA-256 of the zip file bytes, hex-encoded.
    static func sha256Hex(ofFileAt fileURL: URL) throws -> String {
        print("\(Self.self).\(#function) — \(fileURL.path)")
        let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
        let digest = SHA256.hash(data: data)
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        print("\(Self.self).\(#function) — \(hex)")
        return hex
    }
}

// MARK: - Entry Point

let scriptURL = URL(fileURLWithPath: CommandLine.arguments[0])
let packageURL = scriptURL
    .deletingLastPathComponent()
    .appendingPathComponent("Package.swift")
let manifest = PackageManifest(fileURL: packageURL)

do {
    let binaryUrl = try manifest.binaryUrl()
    let downloadedZip = try await ArtifactDownloader().download(from: binaryUrl)
    let checksum = try SwiftPackageChecksum.sha256Hex(ofFileAt: downloadedZip)
    try manifest.updateChecksum(to: checksum)
    print("Done.")
} catch {
    FileHandle.standardError.write(Data("Error: \(error.localizedDescription)\n".utf8))
    exit(1)
}
