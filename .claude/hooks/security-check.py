#!/usr/bin/env python3
"""
Security reminder hook for Edit|Write operations.
Checks for common security anti-patterns and warns Claude.
Runs as PreToolUse hook — exit 0 always (advisory, not blocking).
"""

import json
import sys
import re

PATTERNS = [
    {
        "name": "SQL Injection",
        "regex": r"(f['\"].*SELECT|f['\"].*INSERT|f['\"].*UPDATE|f['\"].*DELETE|\$\{.*\}.*(?:SELECT|INSERT|UPDATE|DELETE)|`\s*(?:SELECT|INSERT|UPDATE|DELETE).*\$\{)",
        "message": "Possible SQL injection — use parameterized queries instead of string interpolation.",
        "severity": "CRITICAL",
    },
    {
        "name": "XSS via innerHTML",
        "regex": r"(innerHTML\s*=|dangerouslySetInnerHTML|v-html\s*=)",
        "message": "Potential XSS — avoid innerHTML/dangerouslySetInnerHTML with user input. Use textContent or sanitize.",
        "severity": "HIGH",
    },
    {
        "name": "Command Injection",
        "regex": r"(exec\(|child_process\.exec\(|os\.system\(|subprocess\.call\(.*shell\s*=\s*True|execSync\()",
        "message": "Potential command injection — use parameterized commands or execFile instead of exec/shell=True.",
        "severity": "CRITICAL",
    },
    {
        "name": "Eval Usage",
        "regex": r"(\beval\s*\(|\bFunction\s*\(.*\)\s*\(|new\s+Function\()",
        "message": "eval() is a security risk — avoid executing dynamic code. Use JSON.parse for data, or a proper parser.",
        "severity": "HIGH",
    },
    {
        "name": "Hardcoded Secrets",
        "regex": r"(password\s*=\s*['\"][^'\"]+['\"]|api_key\s*=\s*['\"][^'\"]+['\"]|secret\s*=\s*['\"][^'\"]+['\"]|token\s*=\s*['\"][A-Za-z0-9+/=]{20,}['\"])",
        "message": "Possible hardcoded secret — use environment variables instead.",
        "severity": "HIGH",
    },
    {
        "name": "Insecure Randomness",
        "regex": r"(Math\.random\(\)|random\.random\(\))",
        "message": "Math.random/random.random is not cryptographically secure — use crypto.randomBytes or secrets module for security-sensitive values.",
        "severity": "MEDIUM",
    },
    {
        "name": "Pickle Deserialization",
        "regex": r"(pickle\.loads?\(|pickle\.Unpickler|joblib\.load\()",
        "message": "Pickle deserialization of untrusted data is a remote code execution risk. Use JSON or a safe serializer.",
        "severity": "CRITICAL",
    },
    {
        "name": "Path Traversal",
        "regex": r"(path\.join\(.*req\.|path\.resolve\(.*req\.|fs\.\w+\(.*req\.|open\(.*request\.)",
        "message": "Possible path traversal — validate and sanitize user-supplied file paths. Use path.normalize and check prefix.",
        "severity": "HIGH",
    },
    {
        "name": "Missing Auth Check",
        "regex": r"(@Public\(\)|@SkipAuth\(\)|security\s*:\s*\[\]|authentication\s*:\s*false)",
        "message": "Endpoint marked as public/no-auth — verify this is intentional and not exposing sensitive data.",
        "severity": "MEDIUM",
    },
]


def check_content(content: str) -> list:
    findings = []
    for pattern in PATTERNS:
        if re.search(pattern["regex"], content, re.IGNORECASE | re.MULTILINE):
            findings.append(pattern)
    return findings


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    tool_input = data.get("tool_input", {})
    content = tool_input.get("content", "") or tool_input.get("new_string", "")

    if not content:
        sys.exit(0)

    findings = check_content(content)

    if findings:
        warnings = []
        for f in findings:
            warnings.append(f"⚠ [{f['severity']}] {f['name']}: {f['message']}")
        # Output as system message (advisory, not blocking)
        print("\n".join(warnings), file=sys.stderr)

    sys.exit(0)


if __name__ == "__main__":
    main()
