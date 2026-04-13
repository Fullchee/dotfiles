#!/usr/bin/swift
// Source file — Raycast runs paste-pr-or-jira-link.sh, which compiles this.

import AppKit
import Foundation

let pasteboard = NSPasteboard.general
guard let clipboardString = pasteboard.string(forType: .string) else {
    print("Clipboard is empty")
    exit(1)
}

let urlString = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)

// Determine link text and canonical URL
var displayText: String
var canonicalURL: String

if urlString.contains("github.com") && urlString.contains("/pull/") {
    // GitHub PR: display the PR number
    guard let prPart = urlString.components(separatedBy: "/pull/").last else { exit(1) }
    let prNumber = prPart.components(separatedBy: "/").first?.components(separatedBy: "?").first ?? "PR"
    displayText = prNumber
    canonicalURL = urlString
} else if urlString.contains("atlassian.net") {
    // Jira: extract issue key (e.g. DEV-4499)
    var issueKey: String? = nil

    // Case 1: /browse/DEV-4499
    if let browseRange = urlString.range(of: "/browse/") {
        let afterBrowse = String(urlString[browseRange.upperBound...])
        issueKey = afterBrowse.components(separatedBy: "/").first?.components(separatedBy: "?").first
    }

    // Case 2: ?selectedIssue=DEV-4499 or &selectedIssue=DEV-4499
    if issueKey == nil, let urlComponents = URLComponents(string: urlString) {
        issueKey = urlComponents.queryItems?.first(where: { $0.name == "selectedIssue" })?.value
    }

    guard let key = issueKey, !key.isEmpty else {
        print("No Jira issue key found in URL")
        exit(1)
    }

    // Derive the base URL from the input (e.g. https://citylitics.atlassian.net)
    let base: String
    if let host = URLComponents(string: urlString)?.host {
        base = "https://\(host)"
    } else {
        base = "https://citylitics.atlassian.net"
    }

    displayText = key
    canonicalURL = "\(base)/browse/\(key)"
} else {
    print("No valid GitHub PR or Jira URL found in clipboard")
    exit(1)
}

guard let url = URL(string: canonicalURL) else {
    print("Invalid URL: \(canonicalURL)")
    exit(1)
}

// Build rich text directly (avoids slow WebKit HTML renderer)
let attrs: [NSAttributedString.Key: Any] = [
    .link: url,
    .font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
]
let attributedString = NSAttributedString(string: displayText, attributes: attrs)

pasteboard.clearContents()
pasteboard.writeObjects([attributedString])

Thread.sleep(forTimeInterval: 0.05)

let appleScriptSource = """
tell application "System Events"
    keystroke "v" using command down
end tell
"""
if let script = NSAppleScript(source: appleScriptSource) {
    var error: NSDictionary?
    script.executeAndReturnError(&error)
}
